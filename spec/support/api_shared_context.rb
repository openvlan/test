# To use when the response is :success and the json has a particular key
RSpec.shared_context 'a successful request' do |root|
  skip 'response status code 200' do
    expect(response).to have_http_status(:success)
  end

  if root.present?
    skip "json response has the '#{root}' key with content" do
      expect(json).not_to be_blank
      expect(json.keys).to contain_exactly(root)
      expect(json[root]).not_to be_blank
    end
  end
end

# To use when the response is :created and the json has a particular key
RSpec.shared_context 'a successful create request' do |root|
  skip 'response status code 201' do
    expect(response).to have_http_status(:created)
  end

  skip "json response has the '#{root}' key with content" do
    expect(json).not_to be_blank
    expect(json.keys).to contain_exactly(root)
    expect(json[root]).not_to be_blank
  end
end

# To use when the response is :unprocessable_entity and the json return the 'errors' key
RSpec.shared_context 'a failed request' do
  skip 'response status code 422' do
    expect(response).to have_http_status(:unprocessable_entity)
  end

  skip "json response has the 'errors' key with content" do
    expect(json).not_to be_blank
    expect(json.keys).to contain_exactly(:errors)
    expect(json[:errors]).not_to be_blank
  end
end

RSpec.shared_context 'an internal server error' do
  it 'response status code 500' do
    expect(response).to have_http_status(:internal_server_error)
  end
end

# To use when the response is :not_found and the json return the 'errors' key
RSpec.shared_context 'a not_found request' do
  skip 'response status code 404' do
    expect(response).to have_http_status(:not_found)
  end

  skip "json response has the 'errors' key with content" do
    expect(json).not_to be_blank
    expect(json.keys).to contain_exactly(:errors)
    expect(json[:errors]).not_to be_blank
  end
end

# To use when the response is :unauthorized and the json return the 'message' key
RSpec.shared_context 'an unauthorized request' do
  it 'response status code 404' do
    expect(response).to have_http_status(:unauthorized)
  end

  it "json response has the 'errors' key with content" do
    expect(json).not_to be_blank
    expect(json.keys).to contain_exactly(:message)
    expect(json[:message]).not_to be_blank
  end
end

# To use when the response is :bad_request and the json return the 'errors' key
RSpec.shared_context 'a bad_request request' do
  skip 'response status code 400' do
    expect(response).to have_http_status(:bad_request)
  end

  skip "json response has the 'errors' key with content" do
    expect(json).not_to be_blank
    expect(json.keys).to contain_exactly(:errors)
    expect(json[:errors]).not_to be_blank
  end
end
