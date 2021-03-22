require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:auth_data) { user.create_new_auth_token }

  let(:headers) do
    {
      'Accept' => 'application/vnd.taskmanager.v2',
      'Content-Type' => Mime[:json].to_s,  
      'access-token' => auth_data['access-token'],
      'uid' => auth_data['uid'],
      'client' => auth_data['client']
    }
  end

  before { host! 'api.taskmanager.test' }


  describe 'GET /auth/validate_token' do
    context 'when the request headers are valid' do
      before do
        get '/auth/validate_token', params: {}, headers: headers
      end

      it 'returns the user id' do        
        expect(json_body[:data][:id].to_i).to eq(user.id)
      end

      it 'returns status code 200' do
        expect(response).to have_http_status(200)        
      end
    end 

    context 'when the request headers are invalid' do
      before do
        headers['access-token'] = 'invalid_token'
        get '/auth/validate_token', params: {}, headers: headers
      end

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end
    end
  end # FIM describe GET

  describe 'POST /auth' do
    before do
      post '/auth', params: user_params.to_json, headers: headers  
    end

    context 'when the request params are valid' do
      let(:user_params) { FactoryGirl.attributes_for(:user) }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns json data for created user' do       
        expect(json_body[:data][:email]).to eq(user_params[:email])
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

  describe 'PUT /auth' do
    before do
      put '/auth', params: user_params.to_json, headers: headers
    end

    context 'when the request params are valid' do
      let(:user_params) { { email: 'new_email@taskmanager.com' } }
      
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns the json data for the update user' do
        expect(json_body[:data][:email]).to eq(user_params[:email])
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

  describe 'DELETE /auth' do
    before do
      delete '/auth', params: {}, headers: headers
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)      
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

