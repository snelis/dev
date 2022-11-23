FROM archlinux/archlinux:base-devel as base

RUN pacman -Syu --needed --noconfirm git

ARG USER=dev
ENV USER=$USER
ARG uid=1000
ARG gid=1000
RUN useradd --system --create-home $USER -u $uid \
  && echo "$USER ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER

# allow use of gosu to execute commands as different user
RUN mkdir -p /usr/local/bin && \
  curl -o /usr/local/bin/gosu -sSL https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64 && \
  chmod +x /usr/local/bin/gosu

# Install yay in userspace
USER $USER
WORKDIR /home/$USER
RUN git clone https://aur.archlinux.org/yay.git \
  && cd yay \
  && makepkg -sri --needed --noconfirm \
  && cd \
  # Clean up
  && rm -rf .cache yay

RUN yay --noconfirm -Syu \
  rust \
  python \
  pyenv pyenv-virtualenv \
  neovim \
  stern \
  helm \
  kubectl \
  docker-compose \
  docker \
  chezmoi \
  tmux \
  zsh starship antigen direnv

RUN yay --noconfirm -Syu \
  zsh-completions \
  zsh-autosuggestions \
  zsh-syntax-highlighting \
  fzf \
  shellcheck \
  powerline 

ENV PATH="/home/$USER/.local/bin:$PATH"
RUN zsh --interactive -c id

RUN echo 'eval "$(starship init zsh)"' > /home/$USER/.zshrc

# Back to root
USER root
RUN usermod -aG docker $USER
RUN chsh -s $(which zsh) $USER

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["zsh"]

FROM base as lvim

RUN LV_BRANCH='release-1.2/neovim-0.8' \
  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) -y

RUN lvim +LvimUpdate +q

FROM lvim as dotfiles
RUN chezmoi init --apply $USER
