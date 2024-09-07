---
title: "Biome VSCode拡張を使っているならとりあえずこの設定にしておけ"
emoji: "🤖"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["vscode", "biome"]
published: true
---

## TL;DR

```json:settings.json
{
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "quickfix.biome": "explicit",
    "source.organizeImports.biome": "explicit"
  },
  "[typescript]": {
    "editor.defaultFormatter": "biomejs.biome"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "biomejs.biome"
  },
  "[javascript]": {
    "editor.defaultFormatter": "biomejs.biome"
  },
}
```

https://biomejs.dev/reference/vscode/

## defaultFormatter はなぜ各言語で設定する必要があるのか

defaultFormatter は settings.json の root に設定する場合と、各言語ごとに設定する場合があります。

```json:settings.json
{
  "editor.defaultFormatter": "esbenp.prettier-vscode", // Prettier を全言語に適用
  "[typescript]": {
    "editor.defaultFormatter": "biomejs.biome" // Biome を言語別に適用、Prettier を上書きする
  }
}
```

この場合、root に設定していても各言語ごとの設定があれば上書きされます。

そして

> ワークスペース設定 > ユーザー設定

の強さ順なので、最終的な設定の優先順位は以下になります。

1. [最強] ワークスペース設定 & 各言語ごとの設定
1. ユーザー設定 & 各言語ごとの設定
1. ワークスペース設定 & 全言語共通の設定
1. [最弱] ユーザー設定 & 全言語共通の設定

なので、ワークスペースに設定してチームメンバーで統一したい場合はユーザー設定に打ち消されないように 1 番目「**ワークスペース設定 & 各言語ごとの設定**」で設定しておくといいでしょう。

## まとめ

Biome はいいぞ。
