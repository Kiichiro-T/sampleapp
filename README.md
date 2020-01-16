# README
## 始め方（毎回やる）

```
$ git clone https://github.com/Kiichiro-T/sampleapp.git
$ docker-compose up -d # コンテナ立ち上げ＆サーバー立ち上げ(localhost:3000)
$ docker-compose run web bundle exec rails db:create # db作成
$ docker-compose run web bundle exec rails db:migrate # マイグレーション
$ docker-compose run web bundle exec rails ○○ # ○○でrailsコマンド使える
$ docker-compose down # コンテナ消去＆サーバーを落とす
```

## コンテナ
- webコンテナ
rails用
- dbコンテナ
MySQL用

## ファイル
html(html.erb)ファイルはapp/views/配下
css(scss)ファイルはapp/assets/stylesheet

## ブランチモデル
- git-flow
master - 本番環境用ブランチ
develop - 開発用ブランチ
feature - developブランチから作る(名前はissue-(GitHubのissue番号))
