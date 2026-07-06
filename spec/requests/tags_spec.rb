require "rails_helper"

RSpec.describe "Tags", type: :request do
  let(:user) { User.create!(email: "author@example.com", password: "password") }
  let(:post_record) { Post.create!(title: "既存記事", body: "本文", user: user) }
  let!(:tag) { Tag.create!(name: "Ruby") }

  before { post_record.tags << tag }

  describe "GET /tags" do
    it "returns http success without login" do
      get tags_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /tags/:id" do
    it "returns http success without login and shows tagged posts" do
      get tag_path(tag)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(post_record.title)
    end
  end

  describe "GET /tags/new" do
    it "redirects to sign in when not logged in" do
      get new_tag_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns http success when logged in" do
      sign_in user
      get new_tag_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /tags" do
    it "redirects to sign in when not logged in" do
      post tags_path, params: { tag: { name: "Rails" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a tag when logged in" do
      sign_in user
      expect do
        post tags_path, params: { tag: { name: "Rails" } }
      end.to change(Tag, :count).by(1)
    end

    it "re-renders the form with unprocessable_content when invalid" do
      sign_in user
      post tags_path, params: { tag: { name: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
