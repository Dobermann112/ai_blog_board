require "rails_helper"

RSpec.describe "Comments", type: :request do
  let(:author) { User.create!(email: "author@example.com", password: "password") }
  let(:commenter) { User.create!(email: "commenter@example.com", password: "password") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password") }
  let!(:post_record) { Post.create!(title: "既存記事", body: "本文", user: author) }

  describe "POST /posts/:post_id/comments" do
    it "redirects to sign in when not logged in" do
      post post_comments_path(post_record), params: { comment: { body: "コメント" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a comment when logged in" do
      sign_in commenter
      expect do
        post post_comments_path(post_record), params: { comment: { body: "コメント" } }
      end.to change(Comment, :count).by(1)
      expect(Comment.last.user).to eq(commenter)
    end

    it "does not create a comment with a blank body" do
      sign_in commenter
      expect do
        post post_comments_path(post_record), params: { comment: { body: "" } }
      end.not_to change(Comment, :count)
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "allows the post owner to comment on their own post" do
      sign_in author
      expect do
        post post_comments_path(post_record), params: { comment: { body: "コメント" } }
      end.to change(Comment, :count).by(1)
    end
  end

  describe "GET /posts/:post_id/comments/:id/edit" do
    let!(:comment) { Comment.create!(body: "コメント", user: commenter, post: post_record) }

    it "redirects to sign in when not logged in" do
      get edit_post_comment_path(post_record, comment)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "allows the comment author to view the edit form" do
      sign_in commenter
      get edit_post_comment_path(post_record, comment)
      expect(response).to have_http_status(:ok)
    end

    it "forbids other users from viewing the edit form" do
      sign_in other_user
      get edit_post_comment_path(post_record, comment)
      expect(response).to redirect_to(root_path)
    end

    it "forbids the post owner (non-author) from viewing the edit form" do
      sign_in author
      get edit_post_comment_path(post_record, comment)
      expect(response).to redirect_to(root_path)
    end
  end

  describe "PATCH /posts/:post_id/comments/:id" do
    let!(:comment) { Comment.create!(body: "元の本文", user: commenter, post: post_record) }

    it "updates the comment when the author is logged in" do
      sign_in commenter
      patch post_comment_path(post_record, comment), params: { comment: { body: "更新後の本文" } }
      expect(comment.reload.body).to eq("更新後の本文")
    end

    it "forbids other users from updating the comment" do
      sign_in other_user
      patch post_comment_path(post_record, comment), params: { comment: { body: "不正な更新" } }
      expect(comment.reload.body).to eq("元の本文")
    end
  end

  describe "DELETE /posts/:post_id/comments/:id" do
    let!(:comment) { Comment.create!(body: "コメント", user: commenter, post: post_record) }

    it "destroys the comment when the author is logged in" do
      sign_in commenter
      expect do
        delete post_comment_path(post_record, comment)
      end.to change(Comment, :count).by(-1)
    end

    it "forbids other users from destroying the comment" do
      sign_in other_user
      expect do
        delete post_comment_path(post_record, comment)
      end.not_to change(Comment, :count)
    end

    it "forbids the post owner (non-author) from destroying the comment" do
      sign_in author
      expect do
        delete post_comment_path(post_record, comment)
      end.not_to change(Comment, :count)
    end
  end

  describe "GET /posts/:id (comment visibility)" do
    it "shows comments to a signed-out visitor" do
      Comment.create!(body: "見えるはずのコメント", user: commenter, post: post_record)
      get post_path(post_record)
      expect(response.body).to include("見えるはずのコメント")
      expect(response.body).to include("ログイン")
    end

    it "does not render a details/summary wrapper when there are fewer than 5 comments" do
      4.times { |i| Comment.create!(body: "コメント#{i}", user: commenter, post: post_record) }
      get post_path(post_record)
      expect(response.body).not_to include("<details")
    end

    it "renders a details/summary wrapper when there are 5 or more comments" do
      5.times { |i| Comment.create!(body: "コメント#{i}", user: commenter, post: post_record) }
      get post_path(post_record)
      expect(response.body).to include("<details")
    end
  end
end
