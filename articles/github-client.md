---
title: "WYSIWYG って地獄なの？ -> 自作 GitHub Client で使おう！-> めちゃくちゃ地獄を見た件"
emoji: "🔖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["github", "wysiwyg"]
published: false
---

## 作ったもの

| GitHub                                               | My GitHub Client                               |
| ---------------------------------------------------- | ---------------------------------------------- |
| ![alt text](/images/github-client/image-4.png =800x) | ![alt text](/images/github-client/image-3.png) |

https://github.com/senkenn/github-client

（気が向いたらスター :star: ください :pray:）

## 動機

- GitHub Issue での Markdown 操作がだるい
  - GitHub Projects & Issues でタスク管理をしていた
  - Markdown でいちいち編集に入る or Preview するのがめんどい
- WYSIWYG 辛いらしい？と興味を持った
  - これをみてそんなに辛いのかと知った
    [【React】リッチテキストエディタ（Quill、Tiptap、Slate...）の考え方や前提知識](https://zenn.dev/meijin/articles/rich-text-editor-basis-knowledge)
  - 自分で実際に作らないと辛さわからないパターンと感じた

-> GitHub Client を WYSIWYG で作れば一石二鳥じゃね？？？

## 要件整理

- 機能面
  - GitHub Issue コメントを WYSIWYG で編集できること
  - ノーステップで編集に入れること
  - UI: GitHub ライク
  - GitHub にコピペした画像もプレビューできること
- 技術面
  - wysiwyg editor: TipTap （上の記事見てなんか良さそうだったから）
  - md to html: markdown-it （ゆうめいだったから）
  - html to md: Turndown （ゆうめいだったから）
- おまけ技術
  - Web フレームワーク・ライブラリ: React + Vite
  - GitHub API クライアント: Octokit
  - 認証：GitHub Access Token
    - `gh auth token` で発行できるの楽だよね
  - ルーティング: Tanstack Router
    - めっちゃ体験良かったですがこの記事では触れません

## 本題： WYSIWYG で地獄を見た

### まずこの自作 GitHub Client を用いるケースはどんなパターンか

このアプリを用いる場合、大きく以下の２つのユースケースがあります。

1. GitHub 上で書いたコメントを WYSIWYG Client で開くパターン
1. この WYSIWYG 自作 Client でコメントを書いて、GitHub に反映するパターン

この両方のニーズを満たせないと使い物になりません。

どちらのほうが実装がつらかったか、２です。

1 が簡単なのは自明だと思います。GitHub 上で書いたコメントは Markdown 形式で保存されているので、 markdown-it で HTML に変換して TipTap に流し込むだけです。 GitHub の Markdown はそんなに特殊ではないので parse も簡単でした。

https://github.com/senkenn/github-client/blob/senkenn-patch-2/src/lib/mdHtmlUtils.ts#L7-L15

なぜ２がつらいのか、以下で説明します。

### なぜ WYSIWYG で書いたものを GitHub に反映するパターンがつらいのか

この場合、以下のような処理フローになります。

1. TipTap のドキュメントを HTML 形式で取得
1. HTML 形式を Markdown 形式に変換 (Turndown)
1. GitHub API でコメントを更新

## サブ題： Private リポジトリ上の画像を表示できない

GitHub にアップロードした画像は

### CDP(Chromium Devetools Protocol)での GitHub 認証の突破

- 画像を GitHub 上でペーストすると GitHub のサーバー[^1]に保存され、その画像リンクが md 上に書かれる。
- Private リポジトリ上の画像は、今回のサードパーティ Client からはもちろん見れない
  - 仕事でタスクを GitHub Projects で管理しており、 Issue コメントををよく使うので Private リポジトリ対応は必須だった

[^1]: ちなみに AWS S3 にリダイレクトされます。

### CDP で cookie を読み出してもいいのか

localhost が GitHub の Cookie を使っているのではなく、Vite のミドルウェアが「サーバ側で」Cookie を付けて GitHub に代理リクエストしています。ブラウザには GitHub の Cookie は流れません。
仕組み

取得元: CDP で起動中の Chrome から github.com の Cookie を読み出し。
送信先: ミドルウェアが Playwright の HTTP クライアントで Cookie: ヘッダを直付けして GitHub にアクセス。
vite.config.ts:176 以降の extraHTTPHeaders.Cookie = <cookies> を参照。
経路: フロントは同一オリジンの GET /api/pw-fetch?url=... を叩く → ミドルウェアが GitHub へ代理取得 → レスポンスのボディだけ返す。
ドメイン制限はサーバ側の HTTP には適用されないため、任意ヘッダを付けられる。
制限: ホストは github.com のみ許可（誤送信防止）。vite.config.ts:160-165
漏えい防止: Set-Cookie を返さず、Content-Type/Length/Cache-Control のみ中継。vite.config.ts:191-199
ポイント

ブラウザの「ドメインごとの Cookie 自動送信」ルールは、ブラウザ → サーバの通信に適用。今回の Cookie 利用はサーバ側の手動ヘッダ付与なので、github.com→localhost のドメイン不一致問題は発生しません。
CORS 回避はプロキシで実現。フロントは同一オリジン /api/pw-fetch へアクセスしているだけです。

## 切り札と妥協案

最終的に取ったワークアラウンドや設計見直し

## 学びと反省

WYSIWYG のメリット/デメリット整理、今後同じ題材にどう臨むか

## まとめと次の一歩

読者への示唆、別アプローチや改善アイデアへの誘導
