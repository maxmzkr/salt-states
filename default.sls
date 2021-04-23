python-is-python3:
  pkg:
    - installed

ipython3:
  pkg:
    - installed

virtualenv:
  pkg:
    - installed

python3-pip:
  pkg:
    - installed

neovim-ppa:
  pkgrepo.managed:
    - ppa: neovim-ppa/unstable

neovim:
  pkg:
    - installed 
    - require:
      - pkgrepo: neovim-ppa

vim-editor-install:
  cmd:
    - run
    - name: update-alternatives --install /usr/bin/editor editor /usr/bin/vim 60
    - unless: update-alternatives --list editor | grep "^/usr/bin/vim$"

vim-editor-auto:
  alternatives:
    - auto
    - name: editor
    - require:
      - cmd: vim-editor-install

vim-vi-install:
  cmd:
    - run
    - name: update-alternatives --install /usr/bin/vi vi /usr/bin/vim 60
    - unless: update-alternatives --list vi | grep "^/usr/bin/vim$"

vim-vi-auto:
  alternatives:
    - auto
    - name: vi 
    - require:
      - cmd: vim-vi-install

nvim-vim-install:
  cmd:
    - run
    - name: update-alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
    - unless: update-alternatives --list vim | grep "^/usr/bin/nvim$"
    - require:
      - pkg: neovim

nvim-vim-auto:
  alternatives:
    - auto
    - name: vim 
    - require:
      - cmd: nvim-vim-install
  
git-ppa:
  pkgrepo.managed:
    - ppa: git-core/ppa

git:
  pkg:
    - installed
    - require:
      - pkgrepo: git-ppa

/home/max/.cache/nvim/back:
  file:
    - directory
    - user: max
    - group: max

/home/max/.cache/nvim/swap:
  file:
    - directory

/home/max/.cache/nvim/undo:
  file:
    - directory

dein-cloned:
  git:
    - cloned
    - name: git@github.com:/Shougo/dein.vim.git
    - target: /home/max/.cache/dein/repos/github.com/Shougo/dein.vim
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

dein-install:
  cmd:
    - run
    - name: vim '+call dein#install()' '+qa!'
    - runas: max
    - require:
      - git: dein-cloned

dotfiles:
  git:
    - cloned
    - name: git@github.com:/maxmzkr/dotfiles.git
    - target: /home/max/dotfiles
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

apt-file:
  pkg:
    - installed

stow:
  pkg:
    - installed

stow-git:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S git
    - require:
      - pkg: stow
      - git: dotfiles

stow-dconf-prep:
  cmd:
    - run
    - name: rm /home/max/.config/dconf/user
    - unless: test -h /home/max/.config/dconf/user
    - require:
      - pkg: stow
      - git: dotfiles

stow-dconf:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S dconf
    - require:
      - pkg: stow
      - git: dotfiles
      - cmd: stow-dconf-prep

stow-neovim:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S neovim
    - require:
      - pkg: neovim
      - git: dotfiles

xclip:
  pkg:
    - installed

dconf-cli:
  pkg:
    - installed

solarized-cloned:
  git:
    - cloned
    - name: git@github.com:aruhier/gnome-terminal-colors-solarized.git
    - target: /home/max/gnome-terminal-colors-solarized
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

solarized-installed:
  cmd:
    - run
    - name: cd /home/max/gnome-terminal-colors-solarized && ./install.sh -s light --install-dircolors -p $(dconf list /org/gnome/terminal/legacy/profiles:/ | sed -e 's/://' | sed -e 's/\///')
    - runas: max
    - require:
      - pkg: dconf-cli
      - git: solarized-cloned

zsh:
  pkg:
    - installed

stow-zsh:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S zsh
    - require:
      - pkg: zsh
      - git: dotfiles


gvm-installed:
  cmd:
    - run
    - name: bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
    - unless: source /home/max/.gvm/scripts/gvm && which gvm
    - runas: max

bison:
  pkg:
    - installed

gcc:
  pkg:
    - installed

make:
  pkg:
    - installed

go-installed:
  cmd:
    - run
    - name: "source /home/max/.gvm/scripts/gvm && gvm install go1.4 -B && gvm use go1.4 && gvm install go1.16.3 && gvm use go1.16.3 --default"
    - unless: source /home/max/.gvm/scripts/gvm && which go
    - runas: max
    - require:
      - cmd: gvm-installed
      - pkg: bison
      - pkg: gcc
      - pkg: make

/home/max/.antigen.zsh:
  file:
    - managed
    - source: https://git.io/antigen
    - skip_verify: true

stow-tmux:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S tmux
    - require:
      - pkg: stow
      - git: dotfiles

tmux-cloned:
  git:
    - cloned
    - name: git@github.com:tmux/tmux.git
    - target: /home/max/tmux
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

automake:
  pkg:
    - installed

libevent-dev:
  pkg:
    - installed

libncurses-dev:
  pkg:
    - installed

tmux-installed:
  cmd:
    - run
    - name: cd /home/max/tmux && sh autogen.sh && ./configure && make install
    - unless: which tmux
    - require:
      - git: tmux-cloned
      - pkg: automake
      - pkg: libevent-dev
      - pkg: libncurses-dev

ripgrep:
  pkg:
    - installed

fzf-cloned:
  git:
    - cloned
    - name: git@github.com:junegunn/fzf.git
    - target: /home/max/.fzf
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

fzf-installed:
  cmd:
    - run
    - name: "source /home/max/.gvm/scripts/gvm && /home/max/.fzf/install --no-update-rc --completion --key-bindings"
    - unless: source /home/max/.fzf.bash && which fzf
    - require:
      - git: fzf-cloned
      - cmd: go-installed
      - pkg: ripgrep
