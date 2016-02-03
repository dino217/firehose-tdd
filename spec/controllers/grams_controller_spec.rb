require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "when the grams#show action is called" do
    it "successfully shows the page if the gram is found" do
      gram = FactoryGirl.create(:gram)
      get :show, id: gram.id
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error if the gram is not found" do
      get :show, id: 'TACOCAT'
      expect(response).to have_http_status(:not_found)

      get :show, id: '1TACOCAT'
      FactoryGirl.create(:gram, id: 1)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#index action" do
    it "successfully shows the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#new action" do
    it "requires users to be logged in" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end

    it "successfully shows the new form" do
      user = FactoryGirl.create(:user)
      sign_in user

      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "grams#create action" do
    it "requires users to be signed in" do
      post :create, gram: {message: 'Hello!'}

      expect(response).to redirect_to new_user_session_path
      expect(Gram.count).to eql 0
    end

    it "successfully creates a new gram in the database" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: {message: 'Hello!'}
      expect(response).to redirect_to root_path

      gram = Gram.last
      expect(gram.message).to eq('Hello!')
      expect(gram.user).to eq(user)
    end

    it "properly deals with validation errors" do
      user = FactoryGirl.create(:user)
      sign_in user

      post :create, gram: {message: ''}
      expect(response).to have_http_status(:unprocessable_entity)
      expect(Gram.count).to eql 0
    end
  end
end
