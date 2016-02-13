require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#destroy" do
    it "should not allow a user to destroy a gram that does not belong to them" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, id: gram.id
      expect(response).to have_http_status(:forbidden)
    end

    it "shouldn't let unauthenticated users destroy a gram" do
      gram = FactoryGirl.create(:gram)
      delete :destroy, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow a user to destroy grams" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user
      delete :destroy, id: gram.id
      expect(response).to redirect_to root_path
      gram = Gram.find_by_id(gram.id)
      expect(gram).to eq nil
    end

    it "should return a 404 message if we cannot find a gram with the id that is specified" do
      user = FactoryGirl.create(:user)
      sign_in user
      delete :destroy, id: 'SPACeDUCK'
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "grams#update" do
    it "should not let users update grams that do not bolong to them" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      patch :update, id: gram.id, gram: {message: "wahoo"}
      expect(response).to have_http_status(:forbidden)
    end

    it "should not let unauthenticated users create a gram" do
      gram = FactoryGirl.create(:gram)
      patch :update, id: gram.id, gram: {message: "Hello"}
      expect(response).to redirect_to new_user_session_path
    end

    it "should allow users to successfully update grams" do
      p = FactoryGirl.create(:gram, message: "Initial Value")
      sign_in p.user
      patch :update, id: p.id, gram: { message: 'Changed' }
      expect(response).to redirect_to root_path
      p.reload
      expect(p.message).to eq "Changed"
    end

    it "should have http 404 error if the gram cannot be found" do
      user = FactoryGirl.create(:user)
      sign_in user
      patch :update, id: "YOLOSWAG", gram: {message: 'Changed'}
      expect(response).to have_http_status(:not_found)
    end

    it "should render the edit form with an http status of unprocessable_entity" do
      gram = FactoryGirl.create(:gram, message: 'Initial Value')
      sign_in gram.user
      patch :update, id: gram.id, gram: {message: ''}
      expect(response).to have_http_status(:unprocessable_entity)
      gram.reload
      expect(gram.message).to eq 'Initial Value'
    end
  end

  describe "grams#edit" do
    it "should not allow a user that did not create the gram to edit" do
      gram = FactoryGirl.create(:gram)
      user = FactoryGirl.create(:user)
      sign_in user
      get :edit, id: gram.id
      expect(response).to have_http_status(:forbidden)
    end

    it "should not let unauthenticated users edit a gram" do
      gram = FactoryGirl.create(:gram)
      get :edit, id: gram.id
      expect(response).to redirect_to new_user_session_path
    end

    it "should successfully show the edit form if the gram is found" do
      gram = FactoryGirl.create(:gram)
      sign_in gram.user
      get :edit, id: gram.id
      expect(response).to have_http_status(:success)
    end

    it "should return a 404 error message if the gram is not found" do
      sign_in FactoryGirl.create(:user)
      get :edit, id: "foobaz"
      expect(response).to have_http_status(:not_found)
    end

  end


  describe "grams#show action" do
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

      post :create, gram: {
        message: 'Hello!',
        picture: fixture_file_upload("/picture.png", 'image/png')
      }
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
