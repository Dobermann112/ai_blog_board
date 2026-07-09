require "rails_helper"

RSpec.describe "Follows", type: :request do
  let(:author) { User.create!(email: "author@example.com", password: "password") }
  let(:fan) { User.create!(email: "fan@example.com", password: "password") }

  describe "POST /users/:user_id/follow" do
    it "redirects to sign in when not logged in" do
      post user_follow_path(author)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a follow when logged in" do
      sign_in fan
      expect { post user_follow_path(author) }.to change(Follow, :count).by(1)
    end

    it "does not create a duplicate follow when followed twice" do
      sign_in fan
      post user_follow_path(author)
      expect { post user_follow_path(author) }.not_to change(Follow, :count)
    end

    it "does not allow a user to follow themselves" do
      sign_in fan
      expect { post user_follow_path(fan) }.not_to change(Follow, :count)
    end
  end

  describe "DELETE /users/:user_id/follow" do
    it "destroys the follow when logged in" do
      sign_in fan
      post user_follow_path(author)

      expect { delete user_follow_path(author) }.to change(Follow, :count).by(-1)
    end
  end

  describe "GET /follows" do
    it "redirects to sign in when not logged in" do
      get follows_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "shows only the current user's followed users" do
      other_fan = User.create!(email: "other_fan@example.com", password: "password")
      fan.follows.create!(followed: author)

      sign_in fan
      get follows_path

      expect(response.body).to include(author.email)
      expect(response.body).not_to include(other_fan.email)
    end
  end
end
