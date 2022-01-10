RSpec::Matchers.define :match_response_schema do |schema|
  match do |response|
    schema_directory = "#{Dir.pwd}/spec/support/api/schemas"
    schema_path = "#{schema_directory}/#{schema}.json"

    schema = Oj.load_file(schema_path)
    JSON::Validator.validate!(schema, response.body)
  end
end
