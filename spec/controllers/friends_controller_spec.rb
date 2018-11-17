require 'rails_helper'

RSpec.describe FriendsController, type: :controller do
  context 'without login' do
    describe 'GET index' do
      it 'should redirect_to new_user_session_path' do
        get :index
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST add_friend' do
      it 'should redirect_to new_user_session_path' do
        post :add_friend
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST accept_request' do
      it 'should redirect_to new_user_session_path' do
        post :accept_request
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
    
    describe 'POST remove_friend' do
      it 'should redirect_to new_user_session_path' do
        post :remove_friend
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
  
  context 'with login' do
    before(:each) do
      @user = FactoryBot.create(:user_with_faction)
      sign_in @user
    end
    
    describe 'GET index' do
      it 'should render index' do
        get :index
        expect(response.status).to eq(200)
      end
    end
    
    describe 'POST add_friend' do
      it 'should add other user as friend' do
        user = FactoryBot.create(:user_with_faction)
        post :add_friend, params: {id: user.id}
        expect(response.status).to eq(200)
        expect(Friendship.count).to eq(1)
      end
      
      it 'should not add self as friend' do
        post :add_friend, params: {id: @user.id}
        expect(response.status).to eq(400)
        expect(Friendship.count).to eq(0)
      end
      
      it 'should not add as friend twice' do
        user = FactoryBot.create(:user_with_faction)
        post :add_friend, params: {id: user.id}
        expect(response.status).to eq(200)
        expect(Friendship.count).to eq(1)
        post :add_friend, params: {id: user.id}
        expect(response.status).to eq(400)
        expect(Friendship.count).to eq(1)
      end
    end
    
    describe 'POST accept_request' do
      before(:each) do
        @user2 = FactoryBot.create(:user_with_faction)
        Friendship.create(user: @user, friend: @user2, accepted: false)
      end
      
      it 'should not be able to accept own request' do
        post :accept_request, params: {id: Friendship.last.id}
        expect(response.status).to eq(400)
        expect(Friendship.last.accepted).to be_falsey
      end
      
      it 'should be able to accept other request' do
        sign_in @user2
        post :accept_request, params: {id: Friendship.last.id}
        expect(response.status).to eq(200)
        expect(Friendship.last.accepted).to be_truthy
      end
      
      it 'should be able to accept request of other friendship' do
        user3 = FactoryBot.create(:user_with_faction)
        sign_in user3
        post :accept_request, params: {id: Friendship.last.id}
        expect(response.status).to eq(400)
        expect(Friendship.last.accepted).to be_falsey
      end
    end
    
    describe 'POST remove_friend' do
      before(:each) do
        @user2 = FactoryBot.create(:user_with_faction)
        Friendship.create(user: @user, friend: @user2, accepted: true)
      end
      
      it 'should be able to remove friendship as user' do
        post :remove_friend, params: {id: @user2.id}
        expect(response.status).to eq(200)
        expect(Friendship.count).to eq(0)
      end
      
      it 'should be able to remove friendship as other user' do
        sign_in @user2
        post :remove_friend, params: {id: @user.id}
        expect(response.status).to eq(200)
        expect(Friendship.count).to eq(0)
      end
      
      it 'should be able to remove friendship as third user' do
        user3 = FactoryBot.create(:user_with_faction)
        sign_in user3
        post :remove_friend, params: {id: @user.id}
        expect(response.status).to eq(400)
        expect(Friendship.count).to eq(1)
      end
    end
  end
end