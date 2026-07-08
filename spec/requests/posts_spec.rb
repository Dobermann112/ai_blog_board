require "rails_helper"

RSpec.describe "Posts", type: :request do
  let(:owner) { User.create!(email: "owner@example.com", password: "password") }
  let(:other_user) { User.create!(email: "other@example.com", password: "password") }
  let!(:post_record) { Post.create!(title: "既存記事", body: "本文", user: owner) }

  describe "GET /" do
    it "returns http success and shows the posts index" do
      get root_path
      expect(response).to have_http_status(:success)
      expect(response.body).to include(post_record.title)
    end
  end

  describe "GET /posts" do
    it "returns http success without login" do
      get posts_path
      expect(response).to have_http_status(:success)
    end

    it "does not display images even when a post has one attached" do
      post_record.image.attach(
        io: Rails.root.join("spec/fixtures/files/sample_image.png").open,
        filename: "sample_image.png",
        content_type: "image/png"
      )

      get posts_path

      expect(response.body).not_to include("<img")
    end

    it "paginates results 8 per page" do
      8.times { |i| Post.create!(title: "追加記事#{i}", body: "本文", user: owner) }

      get posts_path
      expect(response.body).not_to include(post_record.title)

      get posts_path(page: 2)
      expect(response.body).to include(post_record.title)
    end

    it "does not include draft posts" do
      draft = Post.create!(title: "下書き記事", body: nil, user: owner, draft: true)

      get posts_path

      expect(response.body).not_to include(draft.title)
    end
  end

  describe "GET /posts/:id" do
    it "returns http success without login" do
      get post_path(post_record)
      expect(response).to have_http_status(:success)
    end

    it "displays the attached image when present" do
      post_record.image.attach(
        io: Rails.root.join("spec/fixtures/files/sample_image.png").open,
        filename: "sample_image.png",
        content_type: "image/png"
      )

      get post_path(post_record)

      expect(response.body).to include("<img")
    end

    it "does not display an image tag when none is attached" do
      get post_path(post_record)
      expect(response.body).not_to include("<img")
    end

    it "allows the owner to view their own draft" do
      draft = Post.create!(title: "下書き記事", body: nil, user: owner, draft: true)

      sign_in owner
      get post_path(draft)

      expect(response).to have_http_status(:success)
    end

    it "blocks other users from viewing a draft" do
      draft = Post.create!(title: "下書き記事", body: nil, user: owner, draft: true)

      sign_in other_user
      get post_path(draft)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /posts/new" do
    it "redirects to sign in when not logged in" do
      get new_post_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "returns http success when logged in" do
      sign_in owner
      get new_post_path
      expect(response).to have_http_status(:success)
    end

    it "shows a link to quote an existing draft" do
      draft = Post.create!(title: "続きを書く下書き", body: nil, user: owner, draft: true)

      sign_in owner
      get new_post_path

      expect(response.body).to include(draft.title)
    end
  end

  describe "POST /posts" do
    it "redirects to sign in when not logged in" do
      post posts_path, params: { post: { title: "新規記事", body: "本文" } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "creates a post owned by the current user when logged in" do
      sign_in owner
      expect do
        post posts_path, params: { post: { title: "新規記事", body: "本文" } }
      end.to change(Post, :count).by(1)
      expect(Post.last.user).to eq(owner)
    end

    it "associates the selected tags with the created post" do
      tag = Tag.create!(name: "Ruby")
      sign_in owner

      post posts_path, params: { post: { title: "新規記事", body: "本文", tag_ids: [ tag.id ] } }

      expect(Post.last.tags).to eq([ tag ])
    end

    it "attaches the uploaded image" do
      sign_in owner
      image = fixture_file_upload("sample_image.png", "image/png")

      post posts_path, params: { post: { title: "新規記事", body: "本文", image: image } }

      expect(Post.last.image).to be_attached
    end

    it "returns unauthorized as json when not logged in" do
      post posts_path, params: { post: { title: "新規記事", body: "本文" } }, as: :json
      expect(response).to have_http_status(:unauthorized)
    end

    it "re-renders the form with unprocessable_content when invalid" do
      sign_in owner
      post posts_path, params: { post: { title: "", body: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns unprocessable_content as json when invalid" do
      sign_in owner
      post posts_path, params: { post: { title: "", body: "" } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "saves a draft with only a title" do
      sign_in owner

      expect do
        post posts_path, params: { post: { title: "タイトルだけの下書き", body: "" }, draft_submit: "下書き保存" }
      end.to change(Post, :count).by(1)

      created = Post.last
      expect(created).to be_draft
      expect(response).to redirect_to(edit_post_path(created))
    end

    it "does not save a draft when both title and body are blank" do
      sign_in owner

      expect do
        post posts_path, params: { post: { title: "", body: "" }, draft_submit: "下書き保存" }
      end.not_to change(Post, :count)

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "GET /posts/:id/edit" do
    it "redirects the owner successfully" do
      sign_in owner
      get edit_post_path(post_record)
      expect(response).to have_http_status(:success)
    end

    it "redirects other users to root with an alert" do
      sign_in other_user
      get edit_post_path(post_record)
      expect(response).to redirect_to(root_path)
    end

    it "shows a delete button so drafts can be removed without visiting the show page" do
      draft = Post.create!(title: "下書き", body: nil, user: owner, draft: true)

      sign_in owner
      get edit_post_path(draft)

      expect(response.body).to include(post_path(draft))
      expect(response.body).to include("削除")
    end
  end

  describe "PATCH /posts/:id" do
    it "updates the post when the owner requests it" do
      sign_in owner
      patch post_path(post_record), params: { post: { title: "更新後タイトル" } }
      expect(post_record.reload.title).to eq("更新後タイトル")
    end

    it "forbids other users from updating the post" do
      sign_in other_user
      patch post_path(post_record), params: { post: { title: "不正な更新" } }
      expect(post_record.reload.title).not_to eq("不正な更新")
    end

    it "returns forbidden as json for other users" do
      sign_in other_user
      patch post_path(post_record), params: { post: { title: "不正な更新" } }, as: :json
      expect(response).to have_http_status(:forbidden)
    end

    it "re-renders the form with unprocessable_content when invalid" do
      sign_in owner
      patch post_path(post_record), params: { post: { title: "" } }
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "returns unprocessable_content as json when invalid" do
      sign_in owner
      patch post_path(post_record), params: { post: { title: "" } }, as: :json
      expect(response).to have_http_status(:unprocessable_content)
    end

    it "publishes a draft when saved normally with both fields filled" do
      draft = Post.create!(title: "下書き", body: nil, user: owner, draft: true)
      sign_in owner

      patch post_path(draft), params: { post: { body: "本文を追加しました" } }

      draft.reload
      expect(draft).not_to be_draft
      expect(response).to redirect_to(draft)
    end

    it "keeps a post as a draft when saved via the draft button" do
      sign_in owner

      patch post_path(post_record), params: { post: { title: "更新した下書き" }, draft_submit: "下書き保存" }

      post_record.reload
      expect(post_record).to be_draft
      expect(response).to redirect_to(edit_post_path(post_record))
    end
  end

  describe "DELETE /posts/:id" do
    it "destroys the post when the owner requests it" do
      sign_in owner
      expect { delete post_path(post_record) }.to change(Post, :count).by(-1)
    end

    it "forbids other users from destroying the post" do
      sign_in other_user
      expect { delete post_path(post_record) }.not_to change(Post, :count)
    end
  end

  describe "GET /mypage" do
    it "redirects to sign in when not logged in" do
      get mypage_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "shows only the current user's posts" do
      other_post = Post.create!(title: "他人の記事", body: "本文", user: other_user)

      sign_in owner
      get mypage_path

      expect(response.body).to include(post_record.title)
      expect(response.body).not_to include(other_post.title)
    end

    it "shows a subtitle for the user's own posts" do
      sign_in owner
      get mypage_path
      expect(response.body).to include("自分の投稿")
    end

    it "includes the user's own drafts" do
      draft = Post.create!(title: "マイページ表示用下書き", body: nil, user: owner, draft: true)

      sign_in owner
      get mypage_path

      expect(response.body).to include(draft.title)
    end
  end
end
