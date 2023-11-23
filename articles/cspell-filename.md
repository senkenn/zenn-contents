---
title: "cspellでファイル名やフォルダ名のスペルチェックをする"
emoji: "🕌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["cspell", "npm"]
published: true
---

## TL;DR

```sh
git diff --name-only --cached | npx cspell --no-progress --show-context stdin
```

## 引用元

https://github.com/streetsidesoftware/cspell/issues/3063#issuecomment-1155651409

私はlefthookなどのGitフックと組み合わせて使っています。

わかりやすい記事
https://zenn.dev/kimuson/articles/husky_to_lefthook#cspell

それでは良きコーディングライフを！
