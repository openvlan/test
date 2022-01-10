RSpec.shared_context 'an authenticated user' do
  user_data = {
    id: 'f8245403-703f-4f0d-974f-ec23f818391d',
    username: 'dummy',
    email: 'dummy@nilus.org',
    active: false,
    confirmed: false,
    last_login_ip: '127.0.0.1',
    last_login_at: '2018-11-14T15:24:26.815Z',
    token_expire_at: 1_547_479_466,
    profile: {
      first_name: nil,
      last_name: nil,
      cellphone: nil
    }
  }

  let(:user) { Domain::AuthResponse.new(user_data) }
  let(:authorize_user_stubbed) { instance_double(AuthorizeUser) }

  before do
    allow(AuthorizeUser).to receive(:new).and_return(authorize_user_stubbed)
    allow(authorize_user_stubbed).to receive(:call).and_return(authorize_user_stubbed)
    allow(authorize_user_stubbed).to receive(:result).and_return(user)
  end
end
