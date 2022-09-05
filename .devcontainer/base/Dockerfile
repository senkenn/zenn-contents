FROM ubuntu:20.04 AS core

# パッケージダウンロード高速化のため、パッケージサーバーを日本のミラーリングサーバーに変更
RUN sed -i.bak -e "s%http://archive.ubuntu.com/ubuntu/%http://ftp.iij.ad.jp/pub/linux/ubuntu/archive/%g" /etc/apt/sources.list

RUN apt update && apt upgrade -y
RUN apt install -y curl git zsh

# Dokcer
COPY ./docker-install.sh /tmp/docker-install.sh
RUN chmod +x /tmp/docker-install.sh && /tmp/docker-install.sh && rm -f /tmp/docker-install.sh

# Dokcer Compose
COPY ./docker-compose-install.sh /tmp/docker-compose-install.sh
RUN chmod +x /tmp/docker-compose-install.sh && /tmp/docker-compose-install.sh && rm -f /tmp/docker-compose-install.sh

# Volta
RUN curl https://get.volta.sh | bash

# ホームディレクトリの環境変数設定
ENV HOME /root
WORKDIR $HOME

# ZSHの設定
RUN zsh
ENV SHELL /usr/bin/zsh
RUN sed -i.bak "s|$HOME:|$HOME:$SHELL|" /etc/passwd

# ZSH用の拡張機能(prezto)
RUN git clone --recursive https://github.com/sorin-ionescu/prezto.git $HOME/.zprezto
RUN ln -s $HOME/.zprezto/runcoms/zlogin    $HOME/.zlogin \
 && ln -s $HOME/.zprezto/runcoms/zlogout   $HOME/.zlogout \
 && ln -s $HOME/.zprezto/runcoms/zpreztorc $HOME/.zpreztorc \
 && ln -s $HOME/.zprezto/runcoms/zprofile  $HOME/.zprofile \
 && ln -s $HOME/.zprezto/runcoms/zshenv    $HOME/.zshenv \
 && ln -s $HOME/.zprezto/runcoms/zshrc     $HOME/.zshrc
RUN echo "export LANG=ja_JP.UTF-8" >> $HOME/.zshrc

# ZSHのPATHを設定
RUN echo 'export VOLTA_HOME="$HOME/.volta"' >> $HOME/.zshrc
RUN echo 'export PATH="$VOLTA_HOME/bin:$PATH"' >> $HOME/.zshrc
RUN echo 'export PATH="/usr/bin:$PATH"' >> $HOME/.zshrc
RUN echo "zstyle ':prezto:module:prompt' theme 'powerlevel10k'" >> $HOME/.zpreztorc

# p10kの設定ファイルを適用
COPY ./.p10k.zsh /root/.p10k.zsh
RUN echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> $HOME/.zshrc

# SSHの鍵を設定
RUN mkdir $HOME/.ssh
RUN echo 'Host github.com' >> $HOME/.ssh/config \
 && echo '  HostName ssh.github.com' >> $HOME/.ssh/config \
 && echo '  IdentityFile /workspace/.ssh/id_rsa' >> $HOME/.ssh/config \
 && echo '  User git' >> $HOME/.ssh/config \
 && echo '  Port 443' >> $HOME/.ssh/config \
 && echo '  StrictHostKeyChecking no' >> $HOME/.ssh/config

#=======================End of layer: zsh-env  =================

WORKDIR /workspace
