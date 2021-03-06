require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:user) { FactoryGirl.create(:user) }
  let(:user_id) { user.id }
  let(:headers) do
    {
      'Accept' => 'application/vnd.taskmanager.v1',
      'Content-Type' => Mime[:json].to_s,
      'Authorization' => user.auth_token
    }
  end

  before { host! 'api.taskmanager.test' }


  describe 'GET /users/:id' do
    before do
      get "/users/#{user_id}", params: {}, headers: headers
    end

    context 'when the user exists' do
      it 'returns the user' do        
        expect(json_body[:id]).to eq(user_id)
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
  end # FIM describe GET

  describe 'POST /users' do
    before do
      post '/users', params: { user: user_params }.to_json, headers: headers  
    end

    context 'when the request params are valid' do
      let(:user_params) { FactoryGirl.attributes_for(:user) }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns json data for created user' do       
        expect(json_body[:email]).to eq(user_params[:email])
      end
    end

    context 'when the request params are invalid' do
      let(:user_params) { FactoryGirl.attributes_for(:user, email: 'invalid_email@') }
      
      it 'returns status code 422' do
        expect(response).to have_http_status(422)        
      end

      it 'returns the json data for the errors' do        
        expect(json_body).to have_key(:errors)
      end
    end
  end # FIM describe POST

  describe 'PUT /users/:id' do
    before do
      put "/users/#{user_id}", params: { user: user_params }.to_json, headers: headers
    end

    context 'when the request params are valid' do
      let(:user_params) { { email: 'new_email@taskmanager.com' } }
      
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the json data for the update user' do
        expect(json_body[:email]).to eq(user_params[:email])
      end
    end

    context 'when the request params are invalid' do
      let(:user_params) { { email: 'invalid_mail@' } }

      it 'returns status code 422' do
        expect(response).to have_http_status(422)
      end

      it 'returns the json data for the errors' do        
        expect(json_body).to have_key(:errors)
      end      
    end
  end # FIM describe PUT

  describe 'DELETE /users/:id' do
    before do
      delete "/users/#{user_id}", params: {}, headers: headers
    end

    it 'returns status code 204' do
      expect(response).to have_http_status(204)      
    end

    it 'removes the user from database' do
      expect( User.find_by(id: user.id ) ).to be_nil
    end    
  end # FIM describe DELETE
  
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

#  bundle exec spring rspec spec/requests/api/v1/users_spec.rb --format=d

