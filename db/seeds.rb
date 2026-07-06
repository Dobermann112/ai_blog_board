# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

demo_user = User.find_or_create_by!(email: "demo@example.com") do |user|
  user.password = "password"
end

fan_user = User.find_or_create_by!(email: "fan@example.com") do |user|
  user.password = "password"
end

posts = [
  {
    title: "初めてのRuby on Rails開発で学んだこと",
    body: "先日、初めてRuby on Railsでアプリケーションを開発しました。MVCの構成に最初は戸惑いましたが、" \
          "規約に従うことで驚くほどスムーズに機能を追加できることに気づきました。特にActiveRecordの" \
          "マイグレーション機能は、データベースの変更履歴を管理する上でとても便利だと感じています。",
    tags: [ "Ruby", "Rails" ]
  },
  {
    title: "在宅勤務3年目、集中力を保つための工夫",
    body: "在宅勤務を始めてから3年が経ちました。最初は集中力が続かず苦労しましたが、朝のルーティンを" \
          "固定することと、作業時間を25分単位で区切るポモドーロ・テクニックを取り入れてから、" \
          "生産性が大きく改善しました。今回はその具体的な工夫を紹介します。",
    tags: [ "ライフスタイル" ]
  },
  {
    title: "週末に作った自家製パンのレシピ",
    body: "週末、久しぶりに自家製パンを焼きました。強力粉とライ麦粉を7:3の割合で混ぜ、一晩低温発酵させることで、" \
          "香り豊かでもちもちとした食感に仕上がります。焼きたてにバターを乗せるだけで最高の朝食になります。",
    tags: [ "料理" ]
  },
  {
    title: "北海道一人旅で訪れた絶景スポットまとめ",
    body: "先月、3泊4日で北海道を一人旅してきました。美瑛の青い池、富良野のラベンダー畑、" \
          "そして知床五湖の自然の雄大さには圧倒されました。移動はレンタカーが便利で、" \
          "時間を気にせず好きな場所で写真を撮れたのが良かったです。",
    tags: [ "旅行" ]
  },
  {
    title: "読書習慣を継続するための3つのコツ",
    body: "本を読む習慣をつけたくてもなかなか続かない、という方は多いのではないでしょうか。" \
          "私が実践して効果があったのは、寝る前の15分だけ読むと決めること、読みたい本を常に手元に置くこと、" \
          "そして読んだ内容を簡単にメモすることの3つです。",
    tags: [ "ライフスタイル" ]
  },
  {
    title: "ランニングを半年続けて感じた体と心の変化",
    body: "健康のために始めたランニングも、気づけば半年が経ちました。最初は1kmも走れませんでしたが、" \
          "今では10kmを無理なく走れるようになりました。体重の変化以上に、朝のランニング後は" \
          "頭がすっきりして仕事の集中力が上がったことが一番の収穫です。",
    tags: [ "健康" ]
  },
  {
    title: "観葉植物を枯らさずに育てる基本ルール",
    body: "植物を育てるのが苦手だった私が、モンステラとポトスを半年以上元気に育てられています。" \
          "コツは水のやりすぎないこと、そして季節ごとに置き場所の日当たりを見直すことでした。" \
          "土が乾いてから2〜3日待って水やりをするくらいがちょうど良いようです。",
    tags: [ "ライフスタイル" ]
  },
  {
    title: "コーヒー豆の焙煎度合いによる味の違いを飲み比べてみた",
    body: "同じ産地のコーヒー豆でも、焙煎度合いによって驚くほど味わいが変わります。浅煎りは酸味と" \
          "フルーティーな香りが際立ち、深煎りは苦味とコクが強く出る印象でした。自分好みの一杯を" \
          "見つけるために、しばらく飲み比べを続けてみようと思います。",
    tags: [ "料理" ]
  },
  {
    title: "副業でブログを始めて半年経った振り返り",
    body: "副業としてブログを始めて半年が経過しました。最初の3ヶ月はアクセスがほとんどありませんでしたが、" \
          "検索されやすいタイトルの付け方を学んでからは、少しずつ読んでもらえる記事が増えてきました。" \
          "焦らず継続することの大切さを実感しています。",
    tags: [ "ライフスタイル", "Rails" ]
  },
  {
    title: "断捨離を実践して感じた暮らしの変化",
    body: "1年着ていない服や使っていない小物を思い切って手放してみました。部屋がすっきりしただけでなく、" \
          "何を持っているかを把握しやすくなり、買い物で同じようなものを重複して買うことも減りました。" \
          "物を減らすことが心の余裕にもつながると実感しています。",
    tags: [ "ライフスタイル" ]
  }
]

created_posts = posts.map do |post_attributes|
  post = demo_user.posts.find_or_create_by!(title: post_attributes[:title]) do |p|
    p.body = post_attributes[:body]
  end

  tags = post_attributes[:tags].map { |name| Tag.find_or_create_by!(name: name) }
  post.tags = tags
  post
end

# fan_userが最初の3件の記事をお気に入り登録し、お気に入り一覧の動作確認をできるようにする
created_posts.first(3).each do |post|
  fan_user.favorites.find_or_create_by!(post: post)
end
