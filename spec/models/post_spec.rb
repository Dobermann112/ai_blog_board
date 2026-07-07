require "rails_helper"

RSpec.describe Post, type: :model do
  let(:user) { User.create!(email: "author@example.com", password: "password") }

  it "is valid with a title, body, and user" do
    post = Post.new(title: "タイトル", body: "本文", user: user)
    expect(post).to be_valid
  end

  it "is invalid without a title" do
    post = Post.new(title: nil, body: "本文", user: user)
    expect(post).not_to be_valid
  end

  it "is invalid without a body" do
    post = Post.new(title: "タイトル", body: nil, user: user)
    expect(post).not_to be_valid
  end

  it "is invalid without a user" do
    post = Post.new(title: "タイトル", body: "本文", user: nil)
    expect(post).not_to be_valid
  end

  it "is destroyed when its user is destroyed" do
    post = Post.create!(title: "タイトル", body: "本文", user: user)
    expect { user.destroy! }.to change(Post, :count).by(-1)
    expect { post.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "is valid without an image attached" do
    post = Post.new(title: "タイトル", body: "本文", user: user)
    expect(post).to be_valid
    expect(post.image).not_to be_attached
  end

  it "can have an image attached" do
    post = Post.create!(title: "タイトル", body: "本文", user: user)
    post.image.attach(
      io: StringIO.new("fake image data"),
      filename: "sample.png",
      content_type: "image/png"
    )
    expect(post.image).to be_attached
  end
end
