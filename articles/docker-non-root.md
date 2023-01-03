---
title: "DockerコンテナにローカルのUID/GIDでログインできるようにした 〜VSCode Dev Containersを添えて〜"
emoji: "👏"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["docker", "vscode", "linux"]
published: true
---

## 問題提起

Dockerを使って開発しているとローカルのホストとマウントしたいなーと思うことがあると思います。そのとき、ローカルがrootでないユーザーだと、コンテナ内のユーザーとUID/GIDが一致せず、ファイルの保存ができなかったりPermission問題が発生してしまいます。

そこで、

**ローカルの UID/GID でコンテナにログインできるようにする**

ということがこの記事の目的です。

## 作ったもの

[GitHubリポジトリ](https://github.com/senkenn/docker-non-root)

以下の記事を参考にして作りました（~~というかほぼパクリ~~）。詳しいことはこちらの記事をご覧ください。
@[card](https://zenn.dev/anyakichi/articles/73765814e57cba)

ざっくりいうと、Dockerfile内でユーザーを作成したあと、コンテナ作成後に実行される`entrypoint.sh`ファイルで、ローカルのUID/GIDに書き換えるというものです。

この問題を解決するに当たりいくつかの記事を拝見しましたが、多かったのはDockerfile内にローカルのIDを直接書いてユーザーを作成したり、docker runコマンド時に引数に渡したりとひと手間いるものばかりでした。どうにかどんな環境でも自動的に、それもコマンドなしでコンテナに入れないかと探していたらこちらを見つけました。おそらく（スクリプトの書き方に違いはあれど）これがベストプラクティスなんじゃないかと思います。

この記事では指定のユーザーが既に存在していた場合（例えばnodeイメージのnodeユーザー）に対応していなかったので、同じIDのユーザーやグループがある場合は削除するように加筆しました。

```diff sh:entrypoint.sh
#!/bin/bash

export HOME=/home/$CONTAINER_USER

# ディレクトリの uid と gid を調べる
uid=$(stat -c "%u" /workspace)
gid=$(stat -c "%g" /workspace)

if [ "$uid" -ne 0 ]; then
    if [ "$(id -u $CONTAINER_USER)" -ne $uid ]; then
+       # すでに存在しているユーザーがいれば削除
+       EXISTING_USER=$(id -nu $uid)
+       if [ $EXISTING_USER ] ; then
+           userdel -r $EXISTING_USER
+       fi

        # builder ユーザーの uid とカレントディレクトリの uid が異なる場合、
        # builder の uid をカレントディレクトリの uid に変更する。
        # ホームディレクトリは usermod によって正常化される。
        usermod -u $uid $CONTAINER_USER
    fi
    if [ "$(id -g $CONTAINER_USER)" -ne $gid ]; then
+       # すでに存在しているグループがあれば削除
+       EXISTING_GROUP=$(id -ng $gid)
+       if [ $EXISTING_GROUP ] ; then
+           groupdel $EXISTING_GROUP
+       fi

        # builder ユーザーの gid とカレントディレクトリの gid が異なる場合、
        # builder の gid をカレントディレクトリの gid に変更し、ホームディレクトリの
        # gid も正常化する。
        getent group $gid >/dev/null 2>&1 || groupmod -g $gid $CONTAINER_USER
        chgrp -R $gid $HOME
    fi
fi

# このスクリプト自体は root で実行されているので、uid/gid 調整済みの builder ユーザー
# として指定されたコマンドを実行する。
exec setpriv --reuid=$CONTAINER_USER --regid=$CONTAINER_USER --init-groups "$@"
```

VSCodeのDev Containers拡張機能を使えばコマンドなしでコンテナを作ることができます。
フォルダを開いて、コマンドパレットから"Dev Containers: Reopen in Container"を選択すればコンテナが立ち上がります。
`devcontainer.json`内の`remoteUser`でコンテナにログインするユーザーを指定でき、ここでビルド時に作成している`vscode`ユーザーを選択しています。

```json:devcontainer.json
{
  "name": "${localWorkspaceFolderBasename}",
  "service": "app",
  "dockerComposeFile": "docker-compose.yml",
  "workspaceFolder": "/workspace",
  "remoteUser": "vscode"
}
```

## おまけ：rootユーザーでもいいならDocker in/from Dockerが楽

コンテナ内のユーザーがrootでもいいのであれば、一度、rootユーザーのDockerコンテナをつくったあと、その中で更にrootユーザーでコンテナを作る、つまりDocker in/from Dockerが楽だと思います。

Docker内でDocker使いたければ、"Docker in Docker"のイメージを使ったり、デーモンをマウントする"Docker from Docker"がベターだと思いますが、VSCodeだと、公式の方で[`devcontainer.json`に以下を追記すれば使えるよ](https://github.com/devcontainers/features/tree/main/src/docker-in-docker)と書いてあります。

```json:devcontainer.json
"features": {
    "ghcr.io/devcontainers/features/docker-in-docker:2": {}
}
```

ただし、注意点として２点、

* Dev Containersウィンドウを開いたあと、更にそのコンテナ上でDev Containersウィンドウを開けるわけではない。結局CLI上でコンテナを起動できるだけ。
* ビルド時はキャッシュが効かず、毎回時間がかかる。

があるので、Dockerfileに書くほうがいいかな、、
