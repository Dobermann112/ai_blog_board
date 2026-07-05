# Blog Board

ユーザーが会員登録してブログ記事を投稿・公開できるサービスです。記事にはタグを付与でき、他ユーザーの記事に「お気に入り」登録ができます。

詳細な仕様（機能一覧・データモデル・認証認可・テスト/CI方針など）は [docs/SPEC-blog-board.md](docs/SPEC-blog-board.md) を正として参照してください。

## 技術構成

| 領域 | 技術 |
|---|---|
| 言語 | Ruby 4.0.1（`.ruby-version` / `.tool-versions`で固定） |
| フレームワーク | Rails 8.1系（`~> 8.1.2`） |
| DB | PostgreSQL |
| 認証 | devise |
| フロントエンド | Tailwind CSS（tailwindcss-rails）、Turbo/Stimulus/importmap（最小限利用） |
| テスト | RSpec + Capybara（rack_test）、SimpleCov（カバレッジ閾値70%） |
| コード品質 | rubocop-rails-omakase、lefthook（pre-commitでrubocop実行）、brakeman、bundler-audit |
| CI/CD | GitHub Actions（scan_ruby / lint / test）、Dependabot |
| インフラ | docker-compose（Postgresのみ）、Dockerfile + kamal（本番デプロイ）、Procfile.dev、dotenv-rails |

## セットアップ手順

```bash
# 1. Rubyバージョンを準備（rbenv例。.ruby-version / .tool-versionsに4.0.1を明記済み）
rbenv install 4.0.1 --skip-existing
# asdfの場合: asdf install ruby 4.0.1

# 2. 依存関係のインストール
bundle install

# 3. Postgresコンテナを起動
docker compose up -d db

# 4. .envを用意（初回のみ）
cp .env.example .env

# 5. DB作成・マイグレーション（bundle install/ログ・tmpクリアも合わせて実行される）
bin/setup --skip-server

# 6. ダミーデータ投入（任意。ダミーユーザー1件・ダミー記事10件を作成）
bin/rails db:seed

# 7. テスト実行
bundle exec rspec

# 8. 静的解析
bundle exec rubocop
bundle exec brakeman
bundle exec bundler-audit check --update

# 9. 開発サーバー起動（Rails server + Tailwind watch）
bin/dev
```

起動後、`http://localhost:3000` でトップページが表示されます。`bin/rails db:seed` を実行していれば、`demo@example.com` / `password` でログインしてダミー記事を確認できます。

## 主な画面

- トップページ（記事一覧へのリンク）
- 記事一覧（新着順）・記事詳細
- 記事の新規作成・編集（投稿者のみ）
- マイページ（自分が投稿した記事一覧、ヘッダーの自分のメールアドレスから遷移）
- ユーザー登録・ログイン・ログアウト（devise標準画面）

タグ付け・タグ別一覧・お気に入り機能は次フェーズで実装予定です。
