# CLAUDE.md

このファイルは、本リポジトリで実装作業を行う際にClaude Codeが継続的に参照する working agreement である。

## プロジェクトの概要

Blog Board — ユーザーが会員登録してブログ記事を投稿・公開できるサービス。記事にはタグを付与でき、他ユーザーの記事に「お気に入り」登録ができる。

## 正とするファイル

[docs/SPEC-blog-board.md](docs/SPEC-blog-board.md) を実装の正とする。実装内容と本書に差異が生じた場合は、まず本書を更新した上で実装をそれに追従させる。

## 技術スタック

- 言語: Ruby 4.0.1（`.ruby-version` / `.tool-versions` で固定）
- フレームワーク: Rails `~> 8.1.2`（`Gemfile.lock` をコミットし依存を固定）
- DB: PostgreSQL
- 認証: devise（認可は外部gemを使わず `require_login!` / `authorize_owner!` の自前実装）
- フロントエンド: Tailwind CSS（`tailwindcss-rails`）、JSは最小限（`button_to`中心）
- テスト: RSpec + Capybara（`driven_by :rack_test`）、SimpleCov（カバレッジ閾値70%）
- コード品質: rubocop-rails-omakase、lefthook（pre-commitでrubocop実行）、brakeman、bundler-audit
- CI/CD: GitHub Actions（scan_ruby / lint / test の3ジョブ）、Dependabot
- インフラ: docker-compose（Postgresのみ）、Dockerfile、kamal（本番デプロイ用）、Procfile.dev、dotenv-rails

## 実装方針

- Railsの慣習（Rails Way）に寄せる。独自パターンを増やさない
- 過度な抽象化をしない（多少の重複は許容し、早すぎる共通化をしない）
- 既存の構成・パターンを崩さない（一度決めたディレクトリ構成・命名規則を踏襲する）
- シンプルかつ最小構成で実装する（指示されていない機能・オプションを足さない）

## フェーズごとの進め方

指示された範囲のみを実装し、指示されていない機能や先回りの実装をしない。スコープが不明確な場合は実装前に確認する。

## 品質チェック

実装の区切りごとに `bundle exec rspec` と `bundle exec rubocop` を実行し、都度グリーンであることを確認してから次に進む。

## bashコマンド実行時の作法

bashコマンドを実行する際は、何を行うかを日本語の簡易要約として明示する。

## 実装フロー

- 実装前に変更方針・変更予定ファイル・DBの変更有無・リスクをまとめて提示し、承認を得てから実装する
- 要求内容と現在のリポジトリの実際の状況に矛盾や前提の食い違いがある場合は、実装前に必ずユーザーに確認を取る
- 実装前に docs/ 配下・README.md・CLAUDE.md などに実装方針や設計方針の記載がないか確認し、ある場合はそちらに沿って実装する
- 実装後は必ずテスト・ルーティング確認・ブラウザでの動作確認を行い、結果を報告する
- 機能追加・変更を行った際、CLAUDE.md・README.md・docs/SPEC-blog-board.md に記載漏れがあれば併せて更新する

## 完了時の報告フォーマット

実装作業が一区切りついた際は、以下のフォーマットに固定して報告する。

- 変更ファイル一覧
- 実装内容一覧
- DBの変更有無
- テスト結果
- Lint結果
- 手動での動作確認項目（ブラウザで確認すべき操作手順のチェックリスト。自動確認できた範囲とユーザー自身の確認が必要な範囲を明記する）
