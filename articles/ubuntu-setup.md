---
title: "Ubuntu22.04インストール後にやることを（半）自動セットアップできるようにした"
emoji: "✨"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["linux", "ubuntu"]
published: true
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

```sh:ubuntu-setup/zsh/zsh-setup.sh
#!/bin/bash

# install zsh
sudo apt-get install -y zsh
sudo sed -i.bak "s|$HOME:/bin/bash|$HOME:/bin/zsh|" /etc/passwd

# install zsh extension (prezto)
git clone --recursive https://github.com/sorin-ionescu/prezto.git $HOME/.zprezto
ln -s $HOME/.zprezto/runcoms/zlogin    $HOME/.zlogin \
  && ln -s $HOME/.zprezto/runcoms/zlogout   $HOME/.zlogout \
  && ln -s $HOME/.zprezto/runcoms/zpreztorc $HOME/.zpreztorc \
  && ln -s $HOME/.zprezto/runcoms/zprofile  $HOME/.zprofile \
  && ln -s $HOME/.zprezto/runcoms/zshenv    $HOME/.zshenv \
  && ln -s $HOME/.zprezto/runcoms/zshrc     $HOME/.zshrc
echo "zstyle ':prezto:module:prompt' theme 'powerlevel10k'" >> $HOME/.zpreztorc
echo 'alias d="docker"' >> $HOME/.zshrc
echo 'alias dc="docker compose"' >> $HOME/.zshrc
echo 'alias ll="ls -AlF"' >> $HOME/.zshrc
echo '[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh' >> $HOME/.zshrc
cp $HOME/ubuntu-setup/zsh/.p10k.zsh $HOME
```

Zshインストール後、sedコマンドでデフォルトのシェルをZshに変更しています。
後半のechoメドレーはテーマをp10kにしたり、`~/.zshrc`にエイリアスとかを書き込んでいます。
そして予め用意しておいたp10kの設定ファイル`.p10k.zsh`をホーム下にコピーします。

## 2. `ubuntu-setup.sh`ファイルの実行

:::message
ここから先は**Zsh**で実行することを想定しています。他のシェルスクリプトだとうまくいかない場合があります。
:::
引数に環境変数を渡します。

```sh
./ubuntu-setup.sh [Git user name] [Git user email] [Rust Toolchain Version] [Reboot at the end(y/n)]
```

まず引数の数をチェック。足りなかったら突き返します。

```sh:ubuntu-setup.sh
#!/usr/bin/zsh

if [ $# -lt 4 ]; then
  echo Error: Missing arguments
  echo "./ubuntu-setup.sh [Git user name] [Git user email] [Rust Toolchain Version] [Reboot at the end(y/n)]"
  exit
fi
```

次に入力の確認を促します。

```sh:ubuntu-setup.sh
GIT_USERNAME=$1
GIT_USEREMAIL=$2
RUST_TOOLCHAIN=$3
echo "Git User Name         : $1"
echo "Git User Email        : $2"
echo "Rust Toolchain Version: $3"
echo "Reboot at the end(y/n): $4"

read "yn?ok? (y/N): "
case "$yn" in [yY]*) ;; *) echo "abort." ; exit ;; esac
```

こちらを使わせていただきました。
@[card](https://qiita.com/u1and0/items/a628db9644a72b11584c)

## 3. ホーム下のディレクトリ名を日本語から英語へ

```sh:ubuntu-setup.sh
LANG=C xdg-user-dirs-gtk-update
```

参考リンク
@[card](https://www.rough-and-cheap.jp/linux/ubuntu-change-xdg-directory-name)

## 4. システム言語を英語に

```sh:ubuntu-setup.sh
sudo update-locale LANG=en_US.UTF8
```

これには~~なんかかっこいいから以外に~~理由があって、日本語だとVSCodeのフォント幅がアルファベット:日本語 = 1:2になってしまい、とても見づらいのです。

システム言語が日本語⇩
![](/images/ubuntu-setup/2023-01-04-15-57-03.png)

システム言語が英語⇩
![](/images/ubuntu-setup/2023-01-04-16-05-23.png)

もちろん、VSCodeは`editor.fontFamily`でエディター部もターミナル部もフォントを変えられますが、個人的にしっくりくるフォントがありませんでした、、、
今後、VSCode以外にもこのような支障が出てくると考えたらもう英語でいいやとなりました（~~なんかかっこいいし~~）。

じゃあ最初から英語インストールしとけよってなるかもしれませんが、20.04か22.04からかは忘れましたが、日本語でインストールするとMozcがデフォルトでもれなくついてくるし、言語サポートで日本語のインストール促してくれるしでメリットが多いのです。なので一度日本語でインストールしたあとに英語に戻しています。

## 5. Gitの設定

```sh:ubuntu-setup.sh
git config --global user.name $GIT_USERNAME
git config --global user.email $GIT_USEREMAIL
git config --global init.defaultBranch main
git config --global --add safe.directory "*"
```

コマンドライン引数で受け取った値を入れています。

最後のは2022年の4月に脆弱性が発見されたものに対する対策ですね。ワイルドカードはあんま良くないでしょうが、まあシングルユーザーだし、/home下でしか作業しないのでよしとします。
詳しくは以下を参照

@[card](https://github.blog/2022-04-12-git-security-vulnerability-announced/)

## 6. ログインキーリングの削除

```sh:ubuntu-setup.sh
cp $HOME/.local/share/keyrings/login.keyring ./login-bak.keyring && rm -f $HOME/.local/share/keyrings/login.keyring
```

おそらくUbuntuへのログインを自動ログインにすると、VSCodeやChromeを開くときにこんな感じでパスワードを求められると思います。

![](/images/ubuntu-setup/54d8309fff5fbbf0ba6c98649420558f.png)

詳しくは以下を参照

@[card](https://obel.hatenablog.jp/entry/20220126/1643137200)

なのでそのためのログインキーリングの削除ですね。セキュリティ上よろしくないでしょうが、家から持ち運んで外で作業するようなことが少ないのでまあこれも良しとします。
意味があるかはわかりませんが、一応バックアップを残すようにしてあります。

## 7. VSCode

```sh:ubuntu-setup.sh
curl -L "https://go.microsoft.com/fwlink/?LinkID=760868" -o vscode.deb
sudo apt-get install -y ./vscode.deb && rm ./vscode.deb
sudo apt-get install -y python3-venv # for PlatformIO extension
```

venvは、ArudinoやESP32などでPlatformIOを使う機会があるので、そのためです。

VSCodeにもChromeと同じように、設定の同期をすることができますのでおすすめです。MicrosoftかGitHubのアカウントがあれば同期できます。
ちなみに、キーバインドはOSごとに異なるので注意が必要です。WindowsとUbuntuを同期させようといろいろ拡張機能を試しましたが、良さそうなのがありませんでした。もしおすすめの拡張機能をご存知でしたら教えていただきたいです。

## 8. Chrome

```sh:ubuntu-setup.sh
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt-get install -y ./google-chrome-stable_current_amd64.deb && rm ./google-chrome-stable_current_amd64.deb
```

## 9. Discord

```sh:ubuntu-setup.sh
wget -O ./discord.deb "https://discordapp.com/api/download?platform=linux&format=deb"
sudo apt-get install -y ./discord.deb && rm ./discord.deb
```

## 10. Slack

```sh:ubuntu-setup.sh
sudo snap install slack
```

Slackはコマンドラインで最新版を取得する方法が見つからなかったのでSnapでインストールします。
3分くらい時間がかかるし、Snap版はバグが出やすいのであまり使いたくないんですけどね、、、しょうがなく。インストールしてる間にインストールが終わった他のVSCodeとかChromeのアカウントログインでもしておくといいでしょう。

## 11. CopyQ

```sh:ubuntu-setup.sh
sudo apt-get install -y copyq
```

コピー履歴を参照・管理できるツール。

インストール後、設定から「自動的に起動する」にチェック。
![](/images/ubuntu-setup/2023-01-04-23-16-56.png)

メインウィンドウ（コピー履歴の表示）のグローバルショートカットを追加。
Windowsの`Win+V`と同じにしたいのですが、デフォルトでは通知ウィンドウの開閉に割り当たっているので、このあとのgsettingsでUbuntuのショートカットを変更後、`Super(Meta)+V`に割り当てています。
![](/images/ubuntu-setup/2023-01-04-23-17-21.png)

あと、CopyQはスクリーンショットも範囲選択したあとに指を離したら自動的にスクショしてくれてWindowsっぽくて好きなのですが、背景が真っ暗になってコピーしたクリップボード画像も真っ黒になってしまうのです。22.04でWaylandになったせいでしょうかね、、、（同じ人いないかググってみたけど見つからなかった）

## 12. Rust

```sh:ubuntu-setup.sh
sudo apt-get install -y gcc
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --default-toolchain "${RUST_TOOLCHAIN}"
source "$HOME/.cargo/env"
```

公式通りにインストールします。ここもコマンドライン引数で受け取ったToolchainのバージョンを指定。

最後のはこのあと早速cargoを使うので、パスを通すために環境変数を読み込み直しています。

## 13. xremap

```sh:ubuntu-setup.sh
cargo install xremap --features gnome
```

リマッパーです。ホットキーの設定などができます。すげえ人が作ったやべえリマッパーです。詳しいことは作者の開発経緯ブログへどうぞ。

@[card](https://k0kubun.hatenablog.com/entry/xremap)

なお、これに関してはちょっと長くなりそうなので別記事で書きたいと思います。

また、xremapをOS起動とともに自動で起動させるようにします。

```sh:ubuntu-setup.sh
sudo cp $HOME/ubuntu-setup/xremap/xremap.service /etc/systemd/system/
sudo systemctl enable xremap.service
```

## 14. Docker Engine

```sh:ubuntu-setup.sh
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

公式に則ってインストールしています。
@[card](https://docs.docker.com/engine/install/ubuntu/)

私はDocker Desktopがあまり好きではないのでインストールしていません。

そして、sudoなしでもdockerコマンドが使えるようにsudoグループに追加します。

```sh:ubuntu-setup.sh
sudo groupadd docker
sudo usermod -aG docker $USER
```

## 15. Volta

```sh:ubuntu-setup.sh
curl https://get.volta.sh | bash
echo 'export VOLTA_HOME="$HOME/.volta"' >> $HOME/.zshrc
echo 'export PATH="$VOLTA_HOME/bin:$PATH"' >> $HOME/.zshrc
```

nodeやyarnなどのバージョン管理ツールです。

## 16. UbuntuのキーバインドやUIの変更

gsettingsコマンドを使って変更していきます。基本的にWindowsっぽくしています。

```sh:gsettings.sh
# keybindings
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super>Page_Up', '<Super><Alt>Left', '<Control><Super>Left']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super>Page_Down', '<Super><Alt>Right', '<Control><Super>Right']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Control><Super>Up']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Control><Super>Down']"
gsettings set org.gnome.shell.keybindings show-screenshot-ui "['Print', '<Super><Shift>s']"
gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Ctrl><Super>v', '<Super>m']"
gsettings set org.freedesktop.ibus.panel.emoji hotkey "[]" # previous setting: ['<Control>period', '<Control>semicolon']

# UI
gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
gsettings set org.gnome.desktop.interface font-name 'Noto Sans CJK JP 11' # Fix windswitcher extending and retracting up and down.
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "BOTTOM"
gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 24
gsettings set org.gnome.shell favorite-apps "['google-chrome.desktop', 'code.desktop', 'org.gnome.Nautilus.desktop', 'discord.desktop', 'slack_slack.desktop']"

# Others
gsettings set org.gnome.mutter workspaces-only-on-primary false # workspaces on all displays
gsettings set org.gnome.desktop.input-sources sources "[('ibus', 'mozc-jp'), ('xkb', 'jp')]" # Change the order of input sources
gsettings set org.gnome.desktop.session idle-delay "uint32 900"
gsettings set org.gnome.desktop.screensaver lock-enabled false
```

ここらへんは個人の好みですね。基本的にGUIでできることはCUIでできますね。

UIはこんな感じ（ほんとは上のメニューバーも下に位置させたい、、、）
![](/images/ubuntu-setup/2023-01-05-17-09-16.png)

スタイルでダークテーマにしていますが、ここはコマンドで変更したあと、一度設定から「外観」にアクセスしないとダークに切り替わりません。なんだこの仕様、、、

ちなみに、次のコマンドでgsettingsで設定できるコマンドやスキーム名、その値などを一覧表示できます。

```sh
gsettings list-schemas | gsettings list-recursively
```

あとはgrepとかで絞り込んで求めているものを探してました。

## その他 <!-- omit in toc -->

今回は、もともとWindows11が入っていたHPのPavilionのノートPCにUbuntu22.04をインストールしたのですが、いくつか問題がありました。

* 起動時に黒いBIOS画面?で10行くらいの謎のエラー文が出る（問題なく起動できるので今は無視。おそらくドライバがないよとかのエラーだと思われる）
* トラックパッドのスワイプ操作などが動作しない
* 指紋認証が反応しない

今度しっかり調査してUbuntuと相性のいいPCを買いたいですね。

## 今後の展望 <!-- omit in toc -->

* ファイアウォールの設定（今はコメントアウト中）
* すべてが正常にインストールされているかのチェック
