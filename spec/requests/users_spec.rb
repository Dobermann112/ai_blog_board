require "rails_helper"

RSpec.describe "Users", type: :request do
  let(:author) { User.create!(email: "author@example.com", password: "password") }
  let(:fan) { User.create!(email: "fan@example.com", password: "password") }
  let!(:published_post) { Post.create!(title: "公開記事", body: "本文", user: author) }
  let!(:draft_post) { Post.create!(title: "下書き記事", body: "本文", user: author, draft: true) }

  describe "GET /users/:id" do
    it "is accessible without logging in" do
      get user_path(author)
      expect(response).to have_http_status(:ok)
    end

    it "shows only the user's published posts" do
      get user_path(author)
      expect(response.body).to include(published_post.title)
      expect(response.body).not_to include(draft_post.title)
    end

    it "shows a follow button for other signed-in users" do
      sign_in fan
      get user_path(author)
      expect(response.body).to include("フォローする")
    end

    it "shows a following button once followed, and allows unfollowing from the page" do
      fan.follows.create!(followed: author)

      sign_in fan
      get user_path(author)
      expect(response.body).to include("フォロー中")

      expect { delete user_follow_path(author) }.to change(Follow, :count).by(-1)
    end

    it "does not show a follow button to the profile owner" do
      sign_in author
      get user_path(author)
      expect(response.body).not_to include("フォローする")
      expect(response.body).not_to include("フォロー中")
    end
  end
end
