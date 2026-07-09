require "rails_helper"

RSpec.describe Follow, type: :model do
  let(:author) { User.create!(email: "author@example.com", password: "password") }
  let(:fan) { User.create!(email: "fan@example.com", password: "password") }

  it "is valid with a unique follower/followed combination" do
    follow = Follow.new(follower: fan, followed: author)
    expect(follow).to be_valid
  end

  it "is invalid when the same follower follows the same user twice" do
    Follow.create!(follower: fan, followed: author)
    follow = Follow.new(follower: fan, followed: author)
    expect(follow).not_to be_valid
  end

  it "is invalid when a user tries to follow themselves" do
    follow = Follow.new(follower: fan, followed: fan)
    expect(follow).not_to be_valid
    expect(follow.errors[:base]).to include("自分自身をフォローすることはできません")
  end
end
