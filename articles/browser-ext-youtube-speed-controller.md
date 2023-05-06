---
title: "YouTubeの動画再生速度をカテゴリごとに設定できるChrome拡張機能を作った"
emoji: "👻"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["chrome", "youtube", "chrome拡張", "react", "typescript"]
published: true
---

## この記事について

初めてブラウザの拡張機能を作ったので、作ってみた感触や苦労したことなどを書いていきます。

## 前提

Chromeでしか正常に動作しません。

## 作ったもの

拡張機能のポップアップから再生速度が設定できます。ゴミみたいなUIですがとりあえずできればいいのです。マークザッカーバーグバンザイ。
![](/images/browser-ext-youtube-speed-controller/2023-05-04-23-36-35.png)

動画カテゴリはこのYouTube Data APIで取得できるカテゴリ一覧です。
https://developers.google.com/youtube/v3/docs/videoCategories/list?hl=ja

リポジトリはこちら。

https://github.com/senkenn/browser-ext-youtube-speed-controller

コードはなぐり書きなのでかなり汚いです。
なお、こちらのReactを使ったブラウザ拡張機能開発用フレームワークをコピーして開発させていただきました。私自身が使い慣れているReactで開発でき、ホットリロードやポップアップやバックグラウンド実行など拡張機能コンテンツの一通りのサンプルが乗っていたため、採用しました。

https://github.com/sinanbekar/browser-extension-react-typescript-starter

まだ対応してないのかはわからないですが（というよりできないことなのかも？）、`yarn dev`でビルドし直すと拡張機能を読み込み直さなくてはいけないことが少し煩わしく感じました。

あと、開発にあたってこちらのZennの本が大変参考になりました（このフレームワークもこの本から見つけた）。非常によくまとまっていて有料でもおかしくないと感じました。
https://zenn.dev/alvinvin/books/chrome_extension

## 苦労したこと

多分ほとんどの人にはどうでもいいことですが、いくつかハマったのでどうせならと思って残しておきます。

### 新しく動画が再生されたことの検知

新しく動画を再生するとURLが変わるので、URLの変更を検知すればいいわけなんですが、最初調べたときはDOMの変更でURLの変更を検知することしかヒットしなかったので、動画プレイヤー部分のdivタグのIDからDOMを探す方法で勧めていました。

しかしこれには問題があってYouTubeのホームページだと動画プレイヤーDOMがないのでイベントリスナーを作れないことに気づきました。あとから拡張機能ならBackground Scriptで`chrome.tabs.onUpdated`で簡単に検知できることが判明して最終的に以下のようになりました。

https://github.com/senkenn/browser-ext-youtube-speed-controller/blob/3cf42d6e9fd615233e272cab1bb86b05d3d3c940/src/background/index.ts#L20-L32

`changeInfo.url`でURLの変更を検知して`sendMessage`メソッドでContent Script側にURLを送信しています（Content Script側でURLを用いるため）。そしてContent Script側で再生速度を設定する形にしました。

---

### 現在再生している動画のカテゴリの取得

最初は[YouTube Data API](https://developers.google.com/youtube/v3/docs/videos/list?hl=ja)でカテゴリを取得しようとしたんですが、どうやらAPI Keyをクエリパラメータに入れるようです。これではブラウザのログにAPI Keyが残ってしまう可能性があり、使えないとわかって困り果ててしまいました。

なんとか代替案がないか探してみたらHTMLソースにカテゴリの記載があるのを発見！
![](/images/browser-ext-youtube-speed-controller/2023-05-07-02-51-39.png)

（こちらの記事に助けられました）

https://www.ri-techno.com/2021/02/how-to-find-category-on-youtube-video.html

あとはURL変更検知のフックから現在のページのHTMLソースから正規表現で探すだけと思っていたら、YouTubeはどうやらSPA(Single Page Application)らしいので別の動画を再生しても特定のDOMしか変更されず、**画面リロードしない限りカテゴリは読み込まれない**ことがわかりました。

そこで、`fetch`を使ってインラインでHTMLソースを取得することにしました（この方法に気づくまで２日かかった）。

https://github.com/senkenn/browser-ext-youtube-speed-controller/blob/3cf42d6e9fd615233e272cab1bb86b05d3d3c940/src/content/Content.tsx#L75-L76

---

### 再生速度の設定

最後に肝心の再生速度の設定ですが、最初はYouTubeの再生速度変更から設定したのを反映すればいいかと思いました。調べてみたら変更した情報はSession Storageに`yt-player-playback-rate`をキーとして保存されるみたいなので、イベントリスナーで変更を検知すればいいかと思いましたが、カテゴリ一覧が確認できるポップアップからも変えたいなと思い、他の拡張機能の仕様を読み漁り、YouTubeはHTML5で追加された`video`タグを使用しているみたいなのでこれを`document.querySelector`で探し、速度を設定していることがわかりました。

なので私も同じように実装しました。

https://github.com/senkenn/browser-ext-youtube-speed-controller/blob/3cf42d6e9fd615233e272cab1bb86b05d3d3c940/src/content/Content.tsx#L96-L99

## おまけ：Chromeウェブストアへの公開について

ついでにストアに公開してみようとしたらものすごくめんどくさいことがわかりました。調べてみると審査は結構落とされるみたいですし、実際適当に提出したら落とされました。無駄に初期費用の5ドル払って終わりました。

ストアに公開することが目的の人はそれなりの覚悟を持ってやったほうがいいでしょう。

## まとめ（ポエム）

今回、人様のフレームワークを使わせていただいたおかげで楽に開発を進めることができました。大変感謝。
苦労したポイントが多すぎるのでもっと事前調査で、本当に目的を満たすことができるのか慎重に検討すべきだなあと痛感しました。まあ初めてだからある程度紆余曲折するのは致し方ない部分はあるかなとも思ったり。プロジェクトだったら絶対炎上案件でしたね。
