require 'rails_helper'

RSpec.describe GramsController, type: :controller do
  describe "grams#index action" do
    it "successfully shows the page" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end
end
