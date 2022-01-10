class JsonbType < ActiveModel::Type::Value
  include ActiveModel::Type::Helpers::Mutable

  def type
    :jsonb
  end

  def deserialize(value)
    if value.is_a?(::String)
      Oj.load(value) rescue nil # rubocop:todo Style/RescueModifier
    else
      value
    end
  end

  def serialize(value)
    if value.is_a?(Array)
      value = value.map do |item|
        item.is_a?(ActiveSupport::HashWithIndifferentAccess) ? item.to_hash : item
      end
    end
    if value.nil?
      nil
    else
      # The mode is important to prevent symbols in keys
      # more in https://github.com/ohler55/oj/blob/master/pages/Modes.md
      Oj.dump(value, mode: :compat)
    end
  end

  def accessor
    ActiveRecord::Store::StringKeyedHashAccessor
  end
end
