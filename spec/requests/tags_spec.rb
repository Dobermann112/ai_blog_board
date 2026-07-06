require "rails_helper"

RSpec.describe "Tags", type: :request do
  let(:user) { User.create!(email: "author@example.com", password: "password") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password") }
  let(:post_record) { Post.create!(title: "既存記事", body: "本文", user: user) }
  let!(:shared_tag) { Tag.create!(name: "Ruby") }

  before { post_record.tags << shared_tag }

  describe "GET /tags" do
    it "returns http success without login" do
      get tags_path
      expect(response).to have_http_status(:success)
    end

    it "shows shared tags but not other users' private tags" do
      private_tag = Tag.create!(name: "秘密のタグ", user: other_user)

      get tags_path

      expect(response.body).to include(shared_tag.name)
      expect(response.body).not_to include(private_tag.name)
    end
  end

  describe "GET /tags/:id" do
    it "returns http success without login and shows tagged posts" do
      get tag_path(shared_tag)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(post_record.title)
    end
  end

  describe "POST /tags" do
    it "redirects to sign in when not logged in" do
      post tags_path, params: { tag: { name: "Rails" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a tag owned by the current user when logged in" do
      sign_in user
      expect do
        post tags_path, params: { tag: { name: "Rails" } }
      end.to change(Tag, :count).by(1)
      expect(Tag.last.user).to eq(user)
    end

    it "appends a checked checkbox via turbo stream" do
      sign_in user
      post tags_path, params: { tag: { name: "Rails" } }, as: :turbo_stream
      expect(response).to have_http_status(:success)
      expect(response.body).to include("tag_checkboxes")
    end

    it "redirects with an alert when invalid (html)" do
      sign_in user
      post tags_path, params: { tag: { name: "" } }
      expect(response).to redirect_to(posts_path)
    end

    it "returns unprocessable_content via turbo_stream when invalid" do
      sign_in user
      post tags_path, params: { tag: { name: "" } }, as: :turbo_stream
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "allows different users to create tags with the same name" do
      Tag.create!(name: "Ruby on Rails", user: other_user)
      sign_in user
      expect do
        post tags_path, params: { tag: { name: "Ruby on Rails" } }
      end.to change(Tag, :count).by(1)
    end
  end
end
