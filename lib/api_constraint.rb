class ApiConstraint
  attr_reader :version, :default

  def initialize(options)
    @version = options.fetch(:version)
    @default = options[:default]
  end

  def matches?(request)
    match_version_header?(request) || is_default?
  end

  private

  def is_default?
    !!default
  end

  def match_version_header?(request)
    (request.headers[:accept] || '')
      .include?("version=#{version}")
  end
end
