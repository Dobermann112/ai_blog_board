require "rails_helper"

RSpec.describe PostTag, type: :model do
  let(:user) { User.create!(email: "author@example.com", password: "password") }
  let(:post) { Post.create!(title: "タイトル", body: "本文", user: user) }
  let(:tag) { Tag.create!(name: "Ruby") }

  it "is valid with a unique post/tag combination" do
    post_tag = PostTag.new(post: post, tag: tag)
    expect(post_tag).to be_valid
  end

  it "is invalid when the same tag is added to the same post twice" do
    PostTag.create!(post: post, tag: tag)
    post_tag = PostTag.new(post: post, tag: tag)
    expect(post_tag).not_to be_valid
  end

  it "allows the same tag to be used on different posts" do
    other_post = Post.create!(title: "別のタイトル", body: "本文", user: user)
    PostTag.create!(post: post, tag: tag)
    post_tag = PostTag.new(post: other_post, tag: tag)
    expect(post_tag).to be_valid
  end
end
