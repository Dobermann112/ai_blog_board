require "rails_helper"

RSpec.describe "Favorites", type: :request do
  let(:author) { User.create!(email: "author@example.com", password: "password") }
  let(:fan) { User.create!(email: "fan@example.com", password: "password") }
  let!(:post_record) { Post.create!(title: "既存記事", body: "本文", user: author) }

  describe "POST /posts/:post_id/favorite" do
    it "redirects to sign in when not logged in" do
      post post_favorite_path(post_record)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a favorite when logged in" do
      sign_in fan
      expect do
        post post_favorite_path(post_record)
      end.to change(Favorite, :count).by(1)
    end

    it "does not create a duplicate favorite when favorited twice" do
      sign_in fan
      post post_favorite_path(post_record)
      expect do
        post post_favorite_path(post_record)
      end.not_to change(Favorite, :count)
    end

    it "allows a user to favorite their own post" do
      sign_in author
      expect do
        post post_favorite_path(post_record)
      end.to change(Favorite, :count).by(1)
    end
  end

  describe "DELETE /posts/:post_id/favorite" do
    it "destroys the favorite when logged in" do
      sign_in fan
      post post_favorite_path(post_record)

      expect do
        delete post_favorite_path(post_record)
      end.to change(Favorite, :count).by(-1)
    end
  end

  describe "GET /favorites" do
    it "redirects to sign in when not logged in" do
      get favorites_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "shows only the current user's favorited posts" do
      other_post = Post.create!(title: "他人の記事", body: "本文", user: author)
      fan.favorites.create!(post: post_record)

      sign_in fan
      get favorites_path

      expect(response.body).to include(post_record.title)
      expect(response.body).not_to include(other_post.title)
    end
  end
end
