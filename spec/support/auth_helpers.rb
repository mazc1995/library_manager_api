module AuthHelpers
  def auth_headers(user)
    { 'Authorization' => "Bearer #{user.auth_token}" }
  end

  def create_authenticated_user(role: :member)
    user = create(:user, role: role)
    user.update(auth_token: SecureRandom.hex(16))
    user
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end 