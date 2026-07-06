require "rails_helper"

RSpec.describe Tag, type: :model do
  let(:user) { User.create!(email: "author@example.com", password: "password") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password") }

  it "is valid with a unique name" do
    tag = Tag.new(name: "Ruby")
    expect(tag).to be_valid
  end

  it "is invalid without a name" do
    tag = Tag.new(name: nil)
    expect(tag).not_to be_valid
  end

  it "is invalid with a duplicate name for the same owner (nil included)" do
    Tag.create!(name: "Ruby")
    tag = Tag.new(name: "Ruby")
    expect(tag).not_to be_valid
  end

  it "allows different users to have a tag with the same name" do
    Tag.create!(name: "Ruby", user: other_user)
    tag = Tag.new(name: "Ruby", user: user)
    expect(tag).to be_valid
  end

  describe ".visible_to" do
    it "includes shared tags and the given user's own tags, excluding other users' tags" do
      shared_tag = Tag.create!(name: "共有タグ")
      own_tag = Tag.create!(name: "自分のタグ", user: user)
      other_tag = Tag.create!(name: "他人のタグ", user: other_user)

      expect(Tag.visible_to(user)).to contain_exactly(shared_tag, own_tag)
    end

    it "returns only shared tags when no user is given" do
      shared_tag = Tag.create!(name: "共有タグ")
      Tag.create!(name: "自分のタグ", user: user)

      expect(Tag.visible_to(nil)).to contain_exactly(shared_tag)
    end
  end
end
