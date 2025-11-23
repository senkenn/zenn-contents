---
title: "GitHub Client を WYSIWYG で作ってみたらめちゃくちゃめんどかった件"
emoji: "🔖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["github", "wysiwyg"]
published: false
---

## 作ったもの

https://github.com/senkenn/github-client

## 動機

- いちいち編集に入るのがめんどい
- いちいち preview するのがめんどい

-> WYSIWYG じゃね？

## 要件整理

- 目的
  - GitHub Issue コメントを WYSIWYG で編集できるクライアント
  - UI: GitHub ライク
  - GitHub にコピペした画像もプレビューできること
- 技術面
  - wysiwyg editor: TipTap
  - md to html: markdown-it
  - html to md: Turndown

## 実装トライ 1

採用したツールやライブラリ、最初の設計方針と期待

## ハマりポイント

プレビュー同期・複雑な UI 状態・API 連携などで直面した課題

## 切り札と妥協案

最終的に取ったワークアラウンドや設計見直し

## 学びと反省

WYSIWYG のメリット/デメリット整理、今後同じ題材にどう臨むか

## まとめと次の一歩

読者への示唆、別アプローチや改善アイデアへの誘導

##

## CDP(Chromium Devetools Protocol)での GitHub 認証の突破

- 画像を GitHub 上でペーストすると GitHub のサーバー[^1]に保存され、その画像リンクが md 上に書かれる。
- Private リポジトリ上の画像は、今回のサードパーティ Client からはもちろん見れない
  - 仕事でタスクを GitHub Projects で管理しており、 Issue コメントををよく使うので Private リポジトリ対応は必須だった
-

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
