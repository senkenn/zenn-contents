---
title: "X(Twitter)リンクを自動でFixTweetで再送してくれるDiscord BotをRustで作った"
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["discord", "twitter", "rust"]
published: true
---

私は普段よく友達と Discord で会話してまして、X(Twitter)でのポストも度々共有することがあるのですが、2023/12/1 時点での仕様ではポストの中身のコンテンツが表示されなくなっています。

そこで、リンクを fxtwitter.com に書き換えればコンテンツを表示しれくれる[FixTweet](https://github.com/FixTweet/FixTweet)というサービスがあります。原理としては Android/iPhone のブラウザとかでは中身を見れる（エンベッドしてくれる）のと同じですね。

今回はこちらのサービスを使って、x.com/twitter.com の URL を検知して、自動で FixTweet に書き換えて再送してくれる Discord Bot を作ってみました。

![](/images/discord-bot-x2fxtwitter/2023-12-01-02-08-33.png)

また、最近個人的に Rust が熱く、勉強がてら Rust で作ってみました。

https://github.com/senkenn/discord-bot-x2twitter

## もうそういう Discord Bot ありそうじゃない？

あります（作ったあとで気づきました）。

まあ今回は Rust を触ってみたかったというのが大きいので別にいいです。得体の知れないものを使うよりはいいということにしておきます。
FixTweet 公式の Bot は [Things to tackle in the future](https://github.com/FixTweet/FixTweet#things-to-tackle-in-the-future) で言っているようにまだない様ですが、サードパーティ製のものがあります。機能は今回私が作ったのと同じです。

https://top.gg/bot/1164651057243238400

また、エンベッド機能を自前で実装した方もいらっしゃるようです。

https://qiita.com/yussy/items/de478748d0f3f2956780

とくにこだわりがない方はこれらの Bot を使うのが良いかと思います。

## 構成

- Discord Bot ライブラリ: [serenity](https://github.com/serenity-rs/serenity)
- クラウド: [Shuttle](https://www.shuttle.rs/)

こちらの記事を参考にさせていただきました。

https://dev.classmethod.jp/articles/rust-discordbot/

Shuttle で Discord Bot を動作させる際の注意点ですが、デフォルトは 30 分間アクションがないとアイドル状態になります。なので、CLI でアイドル時間を０分に設定しておきました。

```rust
cargo shuttle project start --idle-minutes 0
```

https://docs.shuttle.rs/getting-started/idle-projects#configuring-the-timeout

無料のコミュニティプランでも無制限で使えるのはありがたいですね。

## 書いた Rust コード

実際書いた Rust コードはほんの数十行程度です（ライブラリが素晴らしい）

https://github.com/senkenn/discord-bot-x2twitter/blob/dab1983c44797474a7f630be53dbd75a28cd5766/src/main.rs#L14-L37

正規表現で URL を検知して、FixTweet に書き換えて再送しています。無駄に複数の X リンクがあっても処理できるようにしています。
Result 型はやはり素晴らしいですね。私は TypeScript をよく書きますが、最近個人開発で Result 型を導入しました。

## まとめ

Rust はいいぞ。
