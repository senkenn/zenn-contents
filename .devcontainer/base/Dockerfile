FROM node:18

RUN apt-get update && apt-get install -y sudo zsh

# Add non administrative user
ENV CONTAINER_USER=vscode
ENV PASSWORD=${CONTAINER_USER}
ENV UID=9999
RUN useradd -mu ${UID} -s /bin/bash -G sudo ${CONTAINER_USER} && \
  echo ${CONTAINER_USER}:$PASSWORD | chpasswd && \
  echo "${CONTAINER_USER}   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# ZSHの設定
ENV SHELL /usr/bin/zsh
RUN sudo sed -i.bak "s|/home/${CONTAINER_USER}:|/home/${CONTAINER_USER}:$SHELL|" /etc/passwd

USER vscode
WORKDIR $HOME
RUN zsh

RUN echo $HOME

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
RUN echo "zstyle ':prezto:module:prompt' theme 'powerlevel10k'" >> $HOME/.zpreztorc

# p10kの設定ファイルを適用
COPY ./.p10k.zsh /home/${CONTAINER_USER}
RUN echo '[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh' >> $HOME/.zshrc
RUN echo 'alias ll="ls -AlF"' >> $HOME/.zshrc

COPY ./entrypoint.sh .
ENTRYPOINT [ "./entrypoint.sh" ]
