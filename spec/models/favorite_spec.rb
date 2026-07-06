require "rails_helper"

RSpec.describe Favorite, type: :model do
  let(:author) { User.create!(email: "author@example.com", password: "password") }
  let(:fan) { User.create!(email: "fan@example.com", password: "password") }
  let(:post) { Post.create!(title: "タイトル", body: "本文", user: author) }

  it "is valid with a unique user/post combination" do
    favorite = Favorite.new(user: fan, post: post)
    expect(favorite).to be_valid
  end

  it "is invalid when the same user favorites the same post twice" do
    Favorite.create!(user: fan, post: post)
    favorite = Favorite.new(user: fan, post: post)
    expect(favorite).not_to be_valid
  end

  it "allows a user to favorite their own post" do
    favorite = Favorite.new(user: author, post: post)
    expect(favorite).to be_valid
  end
end
