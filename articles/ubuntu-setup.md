---
title: "Ubuntu22.04インストール後にやることを（半）自動セットアップできるようにした"
emoji: "✨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["linux", "ubuntu"]
published: false
---

最近、自分の開発用PCをWindowsからUbuntuに移行したので、その覚書です。
環境構築中にOSぶっ壊れたり、変な挙動したりと、何回もインストールする羽目になるだろうと思っていて、実際15回くらいインストールし直したので、作っておいてよかったです。

## GitHubリポジトリ <!-- omit in toc -->

@[card](https://github.com/senkenn/ubuntu-setup)

## Usage <!-- omit in toc -->

:::message
ホームディレクトリ直下にクローンすることを前提としています。
:::

1. CLI操作
   ```sh
   cd
   git clone https://github.com/senkenn/ubuntu-setup.git
   cd ubuntu-setup
   ./zsh/zsh-setup.sh # Zshのインストール
   zsh
   ./ubuntu-setup.sh [Git user name] [Git user email] [Rust Toolchain Version] [Reboot at the end(y/n)] # その他Ubuntuの設定
   ```
1. GUI操作
   * 外見のスタイル
   * 日本語キーマップ
   * CopyQの設定

## 1. Zshのインストール

Zsh及び、Preztoを使ってプラグインのPowerlevel10kをインストールします。

https://github.com/senkenn/ubuntu-setup/blob/main/zsh/zsh-setup.sh

5行目でデフォルトのシェルをZshに変更しています。
後半のechoメドレーはテーマをp10kにしたり、`~/.zshrc`にエイリアスとかを書き込んでいます。
そして予め用意しておいたp10kの設定ファイル`.p10k.zsh`をホーム下にコピーします。

## 2. `ubuntu-setup.sh`ファイルの実行

:::message
ここから先は**Zsh**で実行することを想定しています。他のShell Scriptだとうまくいかない場合があります。
:::
引数に環境変数を渡します。

```sh
./ubuntu-setup.sh [Git user name] [Git user email] [Rust Toolchain Version] [Reboot at the end(y/n)]
```

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L1-L18

3 ~ 7行目で引数の数をチェック。足りなかったら突き返します。

12 ~ 18行目で入力の確認を促しています。
こちらを使わせていただきました。
https://qiita.com/u1and0/items/a628db9644a72b11584c

## 3. ホーム下のディレクトリ名を日本語から英語へ

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L20-L21

参考リンク
https://www.rough-and-cheap.jp/linux/ubuntu-change-xdg-directory-name

## 4. システム言語を英語に

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L26-L27

これには~~なんかかっこいいから以外に~~理由があって、日本語だとVSCodeのフォント幅がアルファベット:日本語 = 1:2になってしまい、とても見づらいのです。

システム言語が日本語⇩
![](/images/ubuntu-setup/2023-01-04-15-57-03.png)

システム言語が英語⇩
![](/images/ubuntu-setup/2023-01-04-16-05-23.png)

もちろん、VSCodeは`editor.fontFamily`でエディター部もターミナル部もフォントを変えられますが、個人的にしっくりくるフォントがありませんでした、、、
今後、VSCode以外にもこのような支障が出てくると考えたらもう英語でいいやとなりました（~~なんかかっこいいし~~）。

じゃあ最初から英語インストールしとけよってなるかもしれませんが、20.04か22.04からかは忘れましたが、日本語でインストールするとMozcがデフォルトでもれなくついてくるのです。なので一度日本語でインストールしたあとに英語に戻しています。

## 5. Gitの設定

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L29-L33

コマンドライン引数で受け取った値を入れています。

33行目は2022年の4月に脆弱性が発見されたものに対する対策ですね。ワイルドカードはあんま良くないでしょうが、まあシングルユーザーだし、/home下でしか作業しないのでよしとします。
詳しくは以下を参照

https://github.blog/2022-04-12-git-security-vulnerability-announced/

## 6. ログインキーリングの削除

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L35-L36

おそらくUbuntuへのログインを自動ログインにすると、VSCodeやChromeを開くときにこんな感じでパスワードを求められると思います。

![](/images/ubuntu-setup/54d8309fff5fbbf0ba6c98649420558f.png)

詳しくは以下を参照

https://obel.hatenablog.jp/entry/20220126/1643137200

なのでそのためのログインキーリングの削除ですね。セキュリティ上よろしくないでしょうが、家から持ち運んで外で作業するようなことが少ないのでまあこれも良しとします。
意味があるかはわかりませんが、一応バックアップを残すようにしてあります。

## 7. VSCode

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L42-L45

venvは、ArudinoやESP32などでPlatformIOを使う機会があるので、そのためです。

VSCodeにもChromeと同じような設定の同期をすることができますので、おすすめです。MicrosoftかGitHubのアカウントがあれば同期できます。
ちなみに、キーバインドはOSごとに異なるので注意が必要です。WindowsとUbuntuを同期させようといろいろ拡張機能を試しましたが、良さそうなのがありませんでした。もしおすすめの拡張機能をご存知でしたら教えていただきたいです。

## 8. Chrome

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L47-L49

## 9. Discord

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L51-L53

## 10. Slack

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L55-L56

Slackはコマンドラインで最新版を取得する方法が見つからなかったのでSnapでインストールします。
3分くらい時間がかかるし、Snap版はバグが出やすいのであまり使いたくないんですけどね、、、しょうがなく。インストールしてる間にインストールが終わった他のVSCodeとかChromeのセットアップでもしておくといいでしょう。

## 11. CopyQ

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L58-L59

コピー履歴を参照・管理できるツール。

インストール後、設定から「自動的に起動する」にチェック。
![](/images/ubuntu-setup/2023-01-04-23-16-56.png)

メインウィンドウ（コピー履歴の表示）のグローバルショートカットを追加。
Windowsの`Win+V`と同じにしたいのですが、デフォルトでは通知ウィンドウの開閉に割り当たっているので、このあとのgsettingsでUbuntuのショートカットを変更後、`Super(Meta)+V`に割り当てています。
![](/images/ubuntu-setup/2023-01-04-23-17-21.png)

あと、CopyQはスクリーンショットも範囲選択したあと、指を離したら自動的にスクショしてくれてWindowsっぽくて好きなのですが、背景が真っ暗になってコピーしたクリップボード画像も真っ黒になってしまうのです。22.04でWaylandになったせいでしょうかね、、、（同じ人いないかググってみたけど見つからなかった）

## 12. Rust

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L61-L65

公式通りにインストールします。ここもコマンドライン引数で受け取ったToolchainのバージョンを指定。

65行目はこのあと早速cargoを使うので、パスを通すためにインストール時に生成された`$HOME/.cargo/env`ファイルを読み込んでいます。

## 13. xremap

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L67-L68

リマッパーです。ホットキーの設定などができます。すげえ人が作ったやべえリマッパーです。詳しいことは作者のブログへどうぞ。
なお、これに関してはちょっと長くなりそうなので別記事で書きたいと思います。

https://k0kubun.hatenablog.com/entry/xremap


また、xremapをOS起動とともに自動で起動させるようにします。

https://github.com/senkenn/ubuntu-setup/blob/main/ubuntu-setup.sh#L70-L72

<!--TODO: ここから-->

## 今後の展望 <!-- omit in toc -->

* ファイアウォールの設定（今はコメントアウト中）
* すべてが正常にインストールされているかのチェック
