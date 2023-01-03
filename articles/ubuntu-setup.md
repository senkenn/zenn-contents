---
title: "Ubuntu22.04インストール後にやることを（半）自動セットアップできるようにした"
emoji: "✨"
type: "idea" # tech: 技術記事 / idea: アイデア
topics: ["linux", "ubuntu"]
published: false
---

最近、自分の開発用PCをWindowsからUbuntuに移行したので、その覚書です。
Ubuntuの環境構築中にOSぶっ壊れたり、変な挙動したりと、何回もインストールする羽目になるだろうと予想してた（実際15回くらいインストールし直した）ので、作っておいてよかったです。

## GitHubリポジトリ <!-- omit in toc -->

@[card](https://github.com/senkenn/ubuntu-setup)

### Usage <!-- omit in toc -->

```sh
cd
git clone https://github.com/senkenn/ubuntu-setup.git
cd ubuntu-setup
./zsh/zsh-setup.sh # Zshのインストール
zsh
./ubuntu-setup.sh [Git user name] [Git user email] [Rust Toolchain Version] [Reboot at the end(y/n)] # その他Ubuntuの設定
```

:::message
ホームディレクトリ直下にクローンすることを前提としています。
:::

### 1. Zshのインストール

Petroを使ってPowerlevel10kをインストールします。

```sh:ubuntu-setup/zsh/zsh-setup.sh
#!/bin/bash

# 1. install zsh
sudo apt-get install -y zsh
sudo sed -i.bak "s|$HOME:/bin/bash|$HOME:/bin/zsh|" /etc/passwd

# 2. install zsh extension (prezto)
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

後半のechoメドレーはテーマをp10kにしたり、`~/.zshrc`にエイリアスとかを書き込んでいます。
そして予め用意しておいたp10kの設定ファイル`.p10k.zsh`をホーム下にコピーします。

###
