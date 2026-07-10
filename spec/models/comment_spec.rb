require "rails_helper"

RSpec.describe Comment, type: :model do
  let(:author) { User.create!(email: "author@example.com", password: "password") }
  let(:post_record) { Post.create!(title: "タイトル", body: "本文", user: author) }

  it "is valid with a body, user and post" do
    comment = Comment.new(body: "コメント本文", user: author, post: post_record)
    expect(comment).to be_valid
  end

  it "is invalid without a body" do
    comment = Comment.new(body: nil, user: author, post: post_record)
    expect(comment).not_to be_valid
  end

  it "allows the same user to comment on the same post multiple times" do
    Comment.create!(body: "1回目", user: author, post: post_record)
    comment = Comment.new(body: "2回目", user: author, post: post_record)
    expect(comment).to be_valid
  end
end
