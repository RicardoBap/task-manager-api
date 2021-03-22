require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { FactoryGirl.build(:user) }  

  it { is_expected.to have_many(:tasks).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:email) }
  # it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  it { is_expected.to validate_confirmation_of(:password) }
  it { is_expected.to allow_value('ric_bap@hotmail.com').for(:email) }

  it { is_expected.to validate_uniqueness_of(:auth_token) }

  describe '#info' do
    it 'returns email, created_at and a Token' do
      user.save!
      allow(Devise).to receive(:friendly_token).and_return('abc123xyzTOKEN')

      expect(user.info).to eq("#{user.email} - #{user.created_at} - Token: abc123xyzTOKEN")
    end
  end

  describe '#generate_authentication_token!' do
    it 'generates a unique auth token' do
      allow(Devise).to receive(:friendly_token).and_return('abc123xyzTOKEN')
      user.generate_authentication_token!

      expect(user.auth_token).to eq('abc123xyzTOKEN')
    end

    it 'generates another auth token when the current auth token already has been exixts' do     
      allow(Devise).to receive(:friendly_token).and_return('abc123xyzTOKEN-IGUAL', 'abc123xyzTOKEN-IGUAL', 'abc123xyzNEW-TOKEN')
      existing_user = FactoryGirl.create(:user)
      user.generate_authentication_token!

      expect(user.auth_token).not_to eq(existing_user.auth_token)
    end
  end

end

# rails c
# Devise.friendly_token
