---
title: "GitHubのダークモードでのコードハイライトが見辛かったのでブラウザ拡張機能で見やすくした"
emoji: "😺"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [github, magicss]
published: true
---

Before
![alt text](/images/github-dark-highlight/image.png)

After
![alt text](/images/github-dark-highlight/image-1.png)

## TL;DR

Magic CSS をインストールして

https://chromewebstore.google.com/detail/live-editor-for-css-less/ifhikkcafabcgolfjegfcgloomalapol?hl=en

これで上書きできます

```css
@media (prefers-color-scheme: dark) {
  [data-color-mode="auto"][data-dark-theme="dark"],
  [data-color-mode="auto"][data-dark-theme="dark"] ::backdrop {
    --bgColor-attention-muted: #7e4a03;
  }
}
```

私は `#7e4a03` にしました[^1]。Magic CSS 初めて使いましたが便利ですね

[^1]: そもそももとの RGBA `#bb800926`, Opacity: 0.26 が薄すぎるんですよね。松崎 ◯ げるくらい濃くていいと思います

owari :-)

## 余談

`--bgColor-attention-muted` を見つけるのに 20 分くらいかかった
https://bsky.app/profile/senkenn.bsky.social/post/3kxnh6ocqep25
