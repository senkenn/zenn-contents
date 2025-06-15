---
title: "Ubuntu 24.04 でなぜか突然 iPhone のテザリングができなくなった件"
emoji: "💨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: [ubuntu, linux, iphone, tethering]
published: true
---

ある日突然 Ubuntu 24.04 で iPhone のテザリングができなくなった。調べてもあまり情報が出てこなかったので、個人的な備忘録として残しておく。

## TL;DR

- SSID となる iPhone 名が日本語で長すぎたせい。
- 接続に失敗した Wi-Fi と一致する netplan の設定ファイルを削除して `netplan apply` で再読み込みさせたら解決。
- SSID は UTF-8 エンコード + URL エンコードされ、日本語などは長くなりすぎるので注意。
- 一度接続に失敗すると他の Wi-Fi にも繋がらなくなる可能性あり。

## 事象

いつものように iPhone の設定からテザリングをオンにして、Ubuntu で iPhone の Wi-Fi に接続。

![alt text](/images/ubuntu-tezaling/image-2.drawio.png)

「らん らんらら らんらん」というふざけた名前が私の iPhone です[^1]。

[^1]: この名前にしたときは「まああとで変なこと起こるかもなー」とは思っていた。そして痛い目を見ることになった（アホ）

しかし、なぜか接続できない。以前は接続てきていた記憶があり、iPhone 機種変や PC を変えたわけではない。

Wi-Fi 設定タブで接続しようとすると勝手に Network タブに切り替わり、ここもなんか変。

![invalid network](/images/ubuntu-tezaling/image.png)

"Wired" の項目がない。

↓ 本来の正常な Network タブ

![valid network](/images/ubuntu-tezaling/image-1.png)

そもそも普段は Wi-Fi 設定から接続するときに Network に飛ばされることはない。

なんど試してもつながらないし、PC や iPhone を再起動しても変わらない。

調べても同じような事象がなかなか見つからなかったので、諦めて他の Wi-Fi に接続していたが、ある日他の Wi-Fi にも接続できなくなってしまった。

## 原因判明までの経緯

GUI だと何をやっても解決できなかったので、CUI で接続を試みてみた。

`nmcli device wifi list` で Wi-Fi の一覧は確認できたので、接続を試みてみた。

```bash
❯ nmcli device wifi connect "らん らんらら らんらん" password {パスワード}
Message disconnected from message bus without replying
```

`Message disconnected from message bus without replying` というエラーが出て接続できない。

LLM に聞いて NetworkManager に問題があるかもと。

```bash
sudo systemctl status NetworkManager
```

でステータスを見ても再起動をしてみても特に変化なし。

今度は `/etc/netplan` ディレクトリ見てみたらと。

```bash
❯ ll /etc/netplan
-rw------- 1 root root 644  6月 16 03:03 /etc/netplan/50-cloud-init.yaml
-rw------- 1 root root 698  6月 16 03:03 /etc/netplan/90-NM-0432f754-27e3-40d3-b575-477b4fa11d97.yaml
...
-rw------- 1 root root 571  6月 16 03:03 /etc/netplan/90-NM-fdc8d0ea-2e73-4e25-9b26-0c33e1b40b58.yaml
```

（こんな感じのがあった）

これらは NetworkManager が作成・管理するネットワーク接続プロファイルらしい。

一番新しいファイルを見てみたら

```yaml
❯ sudo cat /etc/netplan/90-NM-4c17c1d4-c64b-4094-b179-dc029ef9a84d.yaml
network:
  version: 2
  wifis:
    NM-4c17c1d4-c64b-4094-b179-dc029ef9a84d:
      renderer: NetworkManager
      match:
        name: "wlo1"
      dhcp4: true
      dhcp6: true
      access-points:
        "227;130;137;227;130;147;32;227;130;137;227;130;147;227;130;137;227;130;137;32;227;130;137;227;130;147;227;130;137;227;130;147;":
          auth:
            key-management: "psk"
          networkmanager:
            uuid: "4c17c1d4-c64b-4094-b179-dc029ef9a84d"
            name: "らん らんらら らんらん"
            passthrough:
              wifi-security.auth-alg: "open"
              ipv6.addr-gen-mode: "default"
              ipv6.ip6-privacy: "-1"
              proxy._: ""
      networkmanager:
        uuid: "4c17c1d4-c64b-4094-b179-dc029ef9a84d"
        name: "らん らんらら らんらん"
```

接続に失敗した iPhone 名が書かれていた。

:::message alert
この netplan の設定ファイルはパスワードやセキュリティ設定なども含まれているので、本来公開してはいけないものです。この設定ファイル自体は接続前なのでパスワードもないですし、SSID も今は異なるのであくまでサンプルとして公開できています。
:::

この状態でとりあえず `netplan apply` を実行してみた。

```bash
❯ sudo netplan apply
Failed to create file “/run/NetworkManager/system-connections/netplan-NM-d28f4382-d49e-4945-ba5b-7767642d2b04-227%3B130%3B137%3B227%3B130%3B147%3B32%3B227%3B130%3B137%3B227%3B130%3B147%3B227%3B130%3B137%3B227%3B130%3B137%3B32%3B227%3B130%3B137%3B227%3B130%3B147%3B227%3B130%3B137%3B227%3B130%3B147%3B.nmconnection.XQ7Z62”: File name too long
```

エラーが出た！`File name too long` と言われ[^2]、何やらエンコードされている `227%3B130%3B137%3B227%3B130%3B147%3B32%3B227%3B130%3B137%3B227%3B130%3B147%3B227%3B130%3B137%3B227%3B130%3B137%3B32%3B227%3B130%3B137%3B227%3B130%3B147%3B227%3B130%3B137%3B227%3B130%3B147%3B` が怪しい。

[^2]: 実際にファイル名である `netplan-NM-d28f4382-d49e-4945-ba5b-7767642d2b04-227%3B130%3B137%3B227%3B130%3B147%3B32%3B227%3B130%3B137%3B227%3B130%3B147%3B227%3B130%3B137%3B227%3B130%3B137%3B32%3B227%3B130%3B137%3B227%3B130%3B147%3B227%3B130%3B137%3B227%3B130%3B147%3B.nmconnection.XQ7Z62` の文字数をカウントしてみると 258 文字だった。ext4 のファイルシステムではファイル名の最大長は 255 文字らしい（ https://ja.wikipedia.org/wiki/Ext4 ）のでギリギリ超えてしまっていた。

LLM に聞いたら UTF-8 エンコード + URL エンコードされたものみたいなので python でデコードしてみる。

```python
from urllib.parse import unquote

encoded_string = "227%3B130%3B137%3B227%3B130%3B147%3B32%3B227%3B130%3B137%3B227%3B130%3B147%3B227%3B130%3B137%3B227%3B130%3B137%3B32%3B227%3B130%3B137%3B227%3B130%3B147%3B227%3B130%3B137%3B227%3B130%3B147%3B227%3B130%3B137%3B227%3B130%3B147%3B"

print(bytes(int(x) for x in unquote(encoded_string).strip(";").split(";")).decode("utf-8"))
# らん らんらら らんらん
```

！！！！

ここへ来てようやく iPhone 名が原因だとわかった（そして名前を変えてから確かに接続できた試しがなかったことを思い出した）。

## 解決方法

接続に失敗した Wi-Fi の設定ファイルを削除して、`netplan apply` で再読み込みさせる。

```bash
sudo rm /etc/netplan/90-NM-4c17c1d4-c64b-4094-b179-dc029ef9a84d.yaml
sudo netplan apply
```

エラーなく `netplan apply` が実行できた（`systemctl restart NetworkManager` も必要かも）。

設定の Network タブにも "Wired" が復活していた。

iPhone 名を英語名などの短いものに変更して、再度接続を試たら接続できた！

## まとめ

- 日本語のような、いかにもシステムエラーを引き起こしそうな名前で、いかにもシステムエラーを引き起こしそうな場所に入れるのはやめましょう。
- CUI は神。
