require 'rails_helper'

RSpec.describe User, type: :model do
  subject { build(:user) }

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:role) }
    it { should validate_presence_of(:password_digest) }
    it { should validate_length_of(:password_digest).is_at_least(8) }
  end

  describe 'enums' do
    it { should define_enum_for(:role).with_values([:member, :librarian]) }
  end

  describe 'secure password' do
    it { should have_secure_password }
  end
end 