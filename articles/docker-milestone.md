---
title: "Dockerマイルストーン"
emoji: "👌"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["docker", "vscode", "react", "mysql"]
published: false
---

## はじめに <!-- omit in toc -->

* この記事の対象者
  この記事はDockerをどのようなステップで勉強していけばいいかわからないというDocker初心者向けです。
* 各ステップのファイルについて
  * ソースコードは[こちら](https://github.com/senkenn/docker-milestone)です。git cloneなり、写経なり自由に使ってください。
  * ブランチ毎に分けています。適時切り替えて参照してください。
* 注意
  細かい用語や説明は省くことがあります。Dockerの詳細は[こちらのQiitaの記事](https://qiita.com/gold-kou/items/44860fbda1a34a001fc1)がおすすめです。
* その他
  この記事はVSCodeの拡張機能の[Markdown Preview Enhanced](https://github.com/shd101wyy/markdown-preview-enhanced)の[Code Chunk](https://github.com/shd101wyy/markdown-preview-enhanced/blob/master/docs/ja-jp/code-chunk.md)が使えます。ぜひお試しください。

## この記事の最終的なゴール <!-- omit in toc -->

Dockerを使って複数コンテナを扱うことを学びたいので、Node.js + React + MySQLを使って簡単なCRUDアプリを作ります。

ちなみに作ったアプリはこんな感じです。
<!-- TODO: ここにゴールの動画載せる -->

## 1. Docker コンテナを作成して起動する

### 1.1. `docker run`コマンドのみで手軽にコンテナを作成＆起動

```sh {cmd}
# イメージのpullとコンテナの起動
docker run -dp 80:80 docker/getting-started --name
```

```sh {cmd}
# 起動中のコンテナ一覧表示
docker ps
```

### 1.2. <http://localhost:80>にアクセス

![docker-getting-start](/images/docker-milestone/2022-09-05-18-23-13.png)
この画面でも説明しているが、`-p [ホストOSのポート(80)]:[コンテナOSのポート(80)]`のポートフォワーディングにより、ホストOSの80番ポートがそのままコンテナOSに繋がることでHTTP通信ができる。

### 1.3. コンテナを止めてみる

```sh {cmd}
docker stop 
```

## 2. Dockerfileを作って自分好みのコンテナを作成する

```Dockerfile : Dockerfile
FROM ubuntu:20.04
```

## 3. `docker run`コマンドでポートフォワーディングする

## 4. `docker run`コマンドでボリュームマウントする

## 5. Docker Compose を使う

## 6. VSCode の Remote Container で コンテナを起動してみる

## その他 <!-- omit in toc -->

このコードはVSCodeで書いています。以下に自分の設定を載せます。

* 拡張機能
  * [Markdown Preview Enhanced](https://marketplace.visualstudio.com/items?itemName=shd101wyy.markdown-preview-enhanced)
  * [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
  * [multi-command](https://marketplace.visualstudio.com/items?itemName=ryuta46.multi-command)
  * [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)

* settings.json

  ```json
    "[markdown]": {
      "editor.defaultFormatter": "DavidAnson.vscode-markdownlint"
    },
    "markdown.extension.preview.autoShowPreviewToSide": true,
    "markdown.extension.toc.orderedList": false,
    "markdown.extension.orderedList.marker": "one",
    "markdown-preview-enhanced.previewTheme": "one-dark.css",
    "markdown-preview-enhanced.enableScriptExecution": true,
    "multiCommand.commands": [
      {
        "command": "multiCommand.saveMarkdown",
        "sequence": [
          "markdownlint.fixAll",
          "markdown.extension.toc.addSecNumbers",
          "workbench.action.files.save"
        ]
      }
    ],
  ```

* keybindings.json

  ```json
      {
          "key": "ctrl+s",
          "command": "extension.multiCommand.execute",
          "args": {
              "command": "multiCommand.saveMarkdown",
          },
          "when": "editorLangId == markdown"
      },

  ```
