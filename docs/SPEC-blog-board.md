# Blog Board 要件定義書

本書は「Blog Board」（ユーザーがブログ記事を投稿・公開できるサービス）の要件定義書であり、以降の実装における**正**とする。実装内容と本書に差異が生じた場合は、本書を更新した上で実装を追従させること。

## 1. サービス概要・目的・想定ユーザー

- **サービス名**: Blog Board（仮称。リポジトリ名 `ai_blog_board` に由来）
- **概要**: ユーザーが会員登録し、ブログ記事を投稿・公開できるサービス。記事にはタグを付与でき、他ユーザーの記事に「お気に入り」登録ができる。
- **目的**: 個人・小規模チームが手軽に情報発信できる場を提供する。
- **想定ユーザー**: アカウントを作成して記事を書く投稿者、記事を閲覧・お気に入り登録する読者（投稿者と読者は同一ユーザーモデル上で区別しない）。

## 2. 用語定義

| 用語 | 説明 |
|---|---|
| User | devise管理のアカウント。記事投稿・お気に入り登録を行う主体 |
| Post | ユーザーが投稿するブログ記事（title, body, 投稿者） |
| Tag | 記事に付与する分類ラベル（name一意） |
| PostTag | PostとTagの中間テーブル |
| Favorite | UserがPostに対して行う「お気に入り」登録の中間テーブル |
| Follow | UserがUserをフォローする関係を表す中間テーブル（フォローする側=follower、される側=followed） |
| Comment | UserがPostに対して行う読者コメント（body、投稿者、対象記事） |

## 3. 機能一覧

- ユーザー登録・ログイン・ログアウト（devise）
- 記事の投稿・編集・削除（投稿者本人のみ）
- 記事の一覧・詳細閲覧（ログイン不要）
- 記事へのタグ付け（複数タグ可）
- タグ別記事一覧の閲覧
- 記事へのお気に入り登録・解除（ログインユーザーのみ、自分の記事も可）
- 自分がお気に入り登録した記事の一覧閲覧
- 自分が投稿した記事の一覧閲覧（マイページ）
- 投稿者へのフォロー登録・解除（ログインユーザーのみ、自分自身はフォロー不可）
- 自分がフォローしているユーザーの一覧閲覧
- 特定ユーザーが投稿した公開記事の一覧閲覧（ユーザー投稿一覧）
- 記事へのコメント投稿・編集・削除（コメント投稿者本人のみ編集・削除可）
- 記事詳細ページでのコメント閲覧（ログイン不要）

## 4. 言語・フレームワークのバージョン方針

- Ruby: **4.0.1** で固定し、`.ruby-version` と `.tool-versions` の両方に明記する（rbenv/asdf双方の利用者と環境を揃えるため）
- Rails: `Gemfile` に `gem "rails", "~> 8.1.2"` と明記する
- `Gemfile.lock` は必ずコミットし、依存バージョンを固定する

## 5. 認証・認可仕様

- 認証には `devise` を用いる（`devise_for :users`、`current_user` / `user_signed_in?` を利用）
- 認可は Pundit や CanCanCan 等の外部gemを使わず、`ApplicationController` に以下のprivateメソッドを定義し `before_action` + `rescue_from` で完結させる
  - `require_login!`: 未ログイン時にアクセスを拒否する
  - `authorize_owner!`: リソースの所有者以外のアクセスを拒否する
- レスポンスは `respond_to` でHTML（`redirect_to` + `flash`）とJSON（`head :unauthorized` 等）の両方をハンドリングする
- `PostsController` を認可実装の規範コントローラとする

## 6. データモデル

### エンティティと関係

```
User 1---* Post           (Post.user_id, dependent: :destroy)
User 1---* Favorite        (Favorite.user_id, dependent: :destroy)
Post 1---* PostTag         (PostTag.post_id, dependent: :destroy)
Post 1---* Favorite        (Favorite.post_id, dependent: :destroy)
Tag  1---* PostTag         (PostTag.tag_id, dependent: :destroy)
User 1---* Follow          (Follow.follower_id, dependent: :destroy)
User 1---* Follow          (Follow.followed_id, dependent: :destroy)
User 1---* Comment         (Comment.user_id, dependent: :destroy)
Post 1---* Comment         (Comment.post_id, dependent: :destroy)
```

### モデル別方針

- `User`: devise標準カラムのみ。`has_many :posts, dependent: :destroy`、`has_many :favorites, dependent: :destroy`
- `Post`: `title`（必須）, `body`（必須）, `user_id`。`belongs_to :user`、`has_many :post_tags, dependent: :destroy`、`has_many :tags, through: :post_tags`、`has_many :favorites, dependent: :destroy`
- `Tag`: `name`（必須・一意）
- `PostTag`（中間テーブル）: `belongs_to :post`、`belongs_to :tag`。`tag_id` に `post_id` スコープの `uniqueness` バリデーションを設定し、DB側でも `post_id + tag_id` の複合ユニークインデックスを張る（アプリ層・DB層の二重チェック）
- `Favorite`（中間テーブル）: `belongs_to :user`、`belongs_to :post`。`post_id` に `user_id` スコープの `uniqueness` バリデーションを設定し、DB側でも `user_id + post_id` の複合ユニークインデックスを張る
- `Follow`（中間テーブル、自己参照）: `belongs_to :follower, class_name: "User"`、`belongs_to :followed, class_name: "User"`。`followed_id` に `follower_id` スコープの `uniqueness` バリデーションを設定し、DB側でも `follower_id + followed_id` の複合ユニークインデックスを張る。加えて、自分自身をフォローできないようにするカスタムバリデーションを設ける（他の中間テーブルにはない要件）
- `Comment`: `body`（必須）, `user_id`, `post_id`。`belongs_to :user`、`belongs_to :post`。同一ユーザーが同一記事に複数コメント可能なため uniqueness バリデーションは設けない

### マイグレーション方針

- 外部キーを持つカラムは `t.references ..., foreign_key: true` で定義し、DBレベルでも外部キー制約を効かせる
- 所有者に紐づくモデルは、所有者側モデルに `dependent: :destroy` をセットで書き、所有者削除時のデータ整合性を担保する
- 自己参照の中間テーブル（`Follow`の`follower_id`/`followed_id`など）はカラム名の接頭辞がテーブル名と一致しないため、`foreign_key: { to_table: :users }` のように参照先テーブルを明示する

## 7. ルーティング方針

- 記事に対する単一アクションのリソース（お気に入り）は `resources :posts do resource :favorite, only: [:create, :destroy] end` のようにネストし、URLとコントローラの対応を素直に保つ
- ユーザーに対する単一アクションのリソース（フォロー）は `resources :users, only: [:show] do resource :follow, only: [:create, :destroy] end` のようにネストする
- タグ別記事一覧は `resources :tags, only: [:index, :show]`
- 記事に対する複数存在しうる子リソース（コメント）は `resources :posts do resources :comments, only: [:create, :edit, :update, :destroy] end` のようにネストする（お気に入りの単数形`resource`とは異なり、複数存在するため複数形`resources`を使う）
- JSON APIは別途 `api/` namespace を切らず、同一コントローラ内で `respond_to` によりHTML/JSONを共存させる

## 8. UI/ビュー構成方針

- レイアウト（`application.html.erb`）にヘッダー/サイドバーメニューを固定配置し、`user_signed_in?` により表示を分岐する
- 一覧表示（記事一覧・お気に入り一覧・タグ別一覧）は共通のパーシャル（`_post_list.html.erb`）に早期に切り出し、複数ページから使い回す
- JavaScriptは極力使わず、お気に入り登録/解除・削除などは `button_to` によるフォーム送信で完結させる（Turbo/Stimulus/importmapは導入するが最小限の利用に留める）
- スタイリングは Tailwind CSS（`tailwindcss-rails`）を用いる

## 9. 画面一覧

| 画面 | 概要 | 認証要否 |
|---|---|---|
| 記事一覧（トップ） | 全記事を新着順に表示 | 不要 |
| 記事詳細 | 本文・タグ・お気に入り状況・コメント一覧を表示 | 不要（お気に入り操作・コメント投稿/編集/削除のみ要ログイン） |
| 記事新規作成 | タイトル・本文・タグを入力して投稿 | 要ログイン |
| 記事編集 | 投稿者本人のみ編集可 | 要ログイン＋所有者 |
| 記事削除 | 投稿者本人のみ削除可 | 要ログイン＋所有者 |
| タグ別記事一覧 | 特定タグが付与された記事一覧 | 不要 |
| お気に入り一覧 | 自分がお気に入り登録した記事一覧 | 要ログイン |
| マイページ（自分の投稿一覧） | 自分が投稿した記事一覧 | 要ログイン |
| フォロー一覧 | 自分がフォローしているユーザーの一覧 | 要ログイン |
| ユーザー投稿一覧 | 特定ユーザーが公開した記事一覧 | 不要（フォロー操作のみ要ログイン） |
| ユーザー登録 / ログイン / ログアウト | devise標準画面 | - |

## 10. テスト方針

- テストフレームワークは `rspec-rails` + `capybara`（`driven_by :rack_test`）を用いる
- テストデータはFactoryBotを使わず `Model.create!` の直書きで統一する
- request specでは `Devise::Test::IntegrationHelpers`（`spec/support/devise.rb`）を用いた `sign_in` ヘルパーでログイン状態を再現する
- `SimpleCov` によるカバレッジ閾値を `spec/rails_helper.rb` に設定し、**最低70%** をCIで強制する

## 11. コード品質・Gitフック

- `.rubocop.yml` は `rubocop-rails-omakase` をベースとし、独自ルールを増やしすぎない
- `lefthook.yml` の pre-commit で `bundle exec rubocop` を実行し、コミット前に静的解析を強制する
- `brakeman`（セキュリティ静的解析）・`bundler-audit`（依存脆弱性監査）を `development` / `test` グループに追加する

## 12. CI/CD

- GitHub Actions（`.github/workflows/ci.yml`）で最低3ジョブを構成する
  - `scan_ruby`: `brakeman` / `bundler-audit`
  - `lint`: `rubocop`（bundlerキャッシュ付き）
  - `test`: Postgresサービスコンテナ + `db:test:prepare` + `rspec`
- `.github/dependabot.yml` で依存関係の自動更新PRを有効化する

## 13. インフラ・ローカル環境

- `docker-compose.yml` はDB（Postgres）のみをコンテナ化し、アプリ本体はローカルで直接実行できる軽量構成とする
- 本番デプロイ用に `Dockerfile` と `kamal` の設定を用意する
- ローカル開発起動用に `Procfile.dev`（`bin/dev` から利用）を用意する
- `.env.example` を用意し、`dotenv-rails` により開発/テスト環境の秘密情報を注入する

## 14. 受け入れ条件

- [ ] `.ruby-version` / `.tool-versions` に Ruby 4.0.1、`Gemfile` に `rails "~> 8.1.2"` が明記され、`Gemfile.lock` がコミットされている
- [ ] devise導入済みで、`require_login!` / `authorize_owner!` による認可が `PostsController` に実装され、HTML/JSON双方に対応している
- [ ] `PostTag` / `Favorite` にアプリ層uniquenessバリデーション＋DB複合ユニークインデックスの二重チェックが実装されている
- [ ] `Follow` にアプリ層uniquenessバリデーション＋DB複合ユニークインデックスの二重チェックに加え、自己フォロー禁止バリデーションが実装されている
- [ ] 所有者に紐づくモデルに `dependent: :destroy` が設定されている
- [ ] マイグレーションが `foreign_key: true` を徹底している
- [ ] `resources :posts do resource :favorite ... end` 形式のネストルーティングが実装されている
- [ ] `resources :users do resource :follow ... end` 形式のネストルーティングと、フォロー一覧・ユーザー投稿一覧画面が実装されている
- [ ] レイアウトにヘッダー/サイドバーがあり、一覧パーシャルが複数画面で再利用されている
- [ ] お気に入り登録・削除が `button_to` のフォーム送信のみで完結している
- [ ] RSpec + Capybara + SimpleCov（閾値70%）が設定され、CIで強制されている
- [ ] rubocop-rails-omakase・lefthook・brakeman・bundler-auditが導入されている
- [ ] GitHub Actionsで scan_ruby / lint / test の3ジョブが構成され、dependabotが有効化されている
- [ ] docker-compose（Postgresのみ）・Dockerfile/kamal・Procfile.dev・.env.example が用意されている
- [ ] `Comment` に `dependent: :destroy` を伴う `User`/`Post` との関連が実装されている
- [ ] `resources :posts do resources :comments ... end` 形式のネストルーティングが実装され、コメントの投稿・編集・削除がコメント投稿者本人のみに制限されている
- [ ] 記事詳細ページでコメントが5件以上ある場合、`<details>/<summary>` によるプルダウン風UIで表示される

## 15. スコープ外（将来検討事項）

- 記事の下書き/公開ステータス管理
- 管理者による記事・ユーザー管理画面
- 検索機能（全文検索等）
