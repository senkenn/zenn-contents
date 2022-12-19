FROM node:18

RUN apt-get update

RUN apt-get install \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  zsh

# Install Docker Engine
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

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
# RUN echo 'export PATH="/usr/bin:$PATH"' >> $HOME/.zshrc
RUN echo "zstyle ':prezto:module:prompt' theme 'powerlevel10k'" >> $HOME/.zpreztorc

# p10kの設定ファイルを適用
COPY ./.p10k.zsh /root/.p10k.zsh
RUN echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> $HOME/.zshrc

WORKDIR /workspace
