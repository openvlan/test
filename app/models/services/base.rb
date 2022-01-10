# rubocop:disable all
module Services
  class Base
    attr_reader :attributes,:errors
    def initialize(attrs = {})
      @attributes = read_map(attrs)
      @dirty = false
      define_methods!
    end

    def ==(other)
      other.id == id
    end

    def read_map(attributes)
      attributes.with_indifferent_access.select do |(key, _value)|
        self.class.attributes.include? key.to_sym
      end
    end

    def read_attribute(attr)
      attributes[attr.to_sym]
    end

    def write_attribute(attr, value)
      dirty!
      attributes[attr.to_sym] = value
    end

    def dirty?
      @dirty
    end

    def dirty!
      @dirty = true
    end

    def inspect
      "<#{self.class.name} \n\t#{attributes.map { |(k, v)| "#{k}: #{v.inspect}" }.join(",\n\t")}>"
    end

    def update(args = {})
      assign_attributes(args)
      save
    end

    def assign_attributes(args = {})
      args.each { |(k, v)| send("#{k}=", v) }
    end

    def save
      response = HTTParty.put(
        build_single_url,
        headers: headers,
        body: {
          self.class.name.demodulize.underscore.singularize => request_body
        }
      )
      if response.parsed_response
        case response.code
        when 200
          reset_cache!
        when 422
          @errors = response.parsed_response['errors']
        else

        end
        end
      self
    end

    def reset_cache!
      Rails.cache.delete_matched "#{self.class.name}::Relation*"
    end

    def as_json
      attributes
    end

    private

    def request_body
      attributes
    end

    def build_single_url
      "#{self.class.service_path}/#{self.class.name.demodulize.underscore.pluralize}/#{id}.json"
    end

    def headers
      self.class.headers
    end

    alias [] read_attribute
    alias []= write_attribute
    alias to_s inspect

    private

    def define_methods!
      self.class.attributes.each do |attribute|
        define_singleton_method(attribute.to_s.to_sym) { attributes[attribute.to_sym] }
        define_singleton_method("#{attribute}=") { |value| attributes[attribute.to_sym] = value }
      end
    end

    class Relation
      include Enumerable
      attr_reader :arguments, :root_key, :root_singular_key, :where_chain
      def initialize(arguments = {}, root_key = nil, root_singular_key = nil)
        @arguments = arguments
        @root_key = root_key
        @root_singular_key = root_singular_key
        @where_chain = {}
      end

      def where(args = {})
        where_chain.merge!(args)
        self
      end

      def find_from_id(id, cache: true, cache_expiration: 2.hours)
        item = Rails.cache.fetch("#{self.class.name}_#{id}", expires_in: cache_expiration) do
          results = raw_single_results(id)
          next unless results
          root_singular_key ? raw_single_results(id)[root_singular_key] : raw_single_results(id)
        end

        return unless item
        self.class.parent.new item
      end

      def raw_single_results(id)
        response = HTTParty.get(
          build_single_url(id),
          headers: headers
        )
        return unless response.parsed_response
        @raw_single_results ||= JSON.parse(response)
      end

      def raw_collection_results
        @raw_collection_results ||= JSON.parse(HTTParty.get(
          build_collection_url,
          headers: headers
        ))
      end

      def collection_results(cache: true, cache_expiration: 2.hours)
        return @collection_results if @collection_results

        items = Rails.cache.fetch("#{self.class.name}_#{serialized_where}_collection", expires_in: cache_expiration) do
          root_key ? raw_collection_results[root_key] : raw_collection_results
        end
        @collection_results = items.map { |i| self.class.parent.new i }
      end

      def inspect
        collection_results
      end

      def each(&block)
        to_a.each(&block)
      end

      def serialized_where
        query_params
      end

      alias to_a collection_results
      delegate :sample, to: :collection_results

      private

      def query_for(key, value)
        "#{key}=#{value}"
      end

      def query_params
        where_chain.map do |(key, value)|
          query_for(key, value)
        end.join('&')
      end

      def build_single_url(id)
        "#{self.class.parent.service_path}/#{self.class.parent.name.demodulize.underscore.pluralize}/#{id}.json?#{query_params}"
      end

      def build_collection_url
        "#{self.class.parent.service_path}/#{self.class.parent.name.demodulize.underscore.pluralize}.json?#{query_params}"
      end

      # TODO: THis doesn't belong here
      def headers
        self.class.parent.headers
      end
    end

    class << self
      attr_writer :root_key, :root_singular_key
      delegate :first, to: :all
      delegate :where, to: :all
      delegate :find_from_id, to: :all

      def all
        find(:all)
      end

      def find(*args)
        case args.first
        when :all then find_every
        else find_from_id(args.first)
        end
      end

      def root_key
        @root_key ||= self.name.demodulize.underscore.pluralize # rubocop:disable Style/RedundantSelf
      end

      def root_singular_key
        @root_singular_key ||= root_key.singularize
      end

      def service_path(path = nil)
        return @service_path ||= superclass.service_path if path.nil?

        @service_path = path
      end

      def belongs_to(attribute, class_name: nil, foreign_key: nil, reload: true)
        class_name ||= "#{parent}::#{attribute.to_s.camelize}".safe_constantize || attribute.to_s.camelize.to_s.safe_constantize
        foreign_key ||= "#{attribute}_id"
        define_method(attribute.to_sym) do
          instance_variable_set("@#{attribute}".to_sym, class_name.find(send(foreign_key))) unless instance_variable_get "@#{attribute}".to_sym
          instance_variable_get "@#{attribute}".to_sym
        end
      end

      def has_many(attribute, class_name: nil, foreign_key: nil, reload: true)
        class_name ||= "#{parent}::#{attribute.to_s.singularize.camelize}".safe_constantize || attribute.to_s.singularize.camelize.to_s.safe_constantize
        foreign_key ||= "#{self.name.demodulize.underscore.singularize}_id"
        (@has_manys ||= {})[:attribute] = { class_name: class_name, foreign_key: foreign_key }
        define_method(attribute.to_s.pluralize.to_sym) do
          instance_variable_set("@#{attribute}".to_sym, class_name.where(foreign_key => id)) unless instance_variable_get "@#{attribute}".to_sym
          instance_variable_get "@#{attribute}".to_sym
        end
      end

      def headers(headers = nil)
        return @headers ||= (superclass.headers || {}) if headers.nil?

        @headers = headers
      end

      def attributes(*attrs)
        return @attributes ||= [] if attrs.empty?

        @attributes = [*attrs]
      end

      private

      def find_every(options = {})
        relation(options)
      end

      def relation(options)
        const_set "Relation".to_sym, Class.new(Services::Base::Relation) if self::Relation == Services::Base::Relation
        self::Relation.new(options, root_key, root_singular_key)
      end
    end
  end
end
# rubocop:enable all
