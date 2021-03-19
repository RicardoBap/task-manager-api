require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:user) { FactoryGirl.create(:user) }
  let(:user_id) { user.id }

  before { host! 'api.taskmanager.test' }


  describe 'GET /users/:id' do
    before do
      headers = { 'Accept' => 'application/vnd.taskmanager.v1' }
      get "/users/#{user_id}", params: {}, headers: headers
    end

    context 'when the user exists' do
      it 'returns the user' do
        user_response = JSON.parse(response.body)
        expect(user_response['id']).to eq(user_id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)        
      end
    end 

    context 'when the user does not exists' do
      let(:user_id) { 1000 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
    end

  end # FIM describe
  
end # FIM

# curl http://api.task-manager.test:3000/users/1
# curl -v http://api.task-manager.test:3000/users/1
# curl -v http://api.task-manager.test:3000/users/2
# curl -v -H 'Accept: application/vnd.taskmanager.v1' http://api.task-manager.test:3000/users/1

# rails c
# User.create(email: 'joao@silva.com', password: '123456', password_confirmation: '123456')
# User.create(email: 'maria@joaquina.com', password: '123456', password_confirmation: '123456')
# User.count
# User.all

