python-is-python3:
  pkg:
    - installed

virtualenv:
  pkg:
    - installed

python3-venv:
  pkg:
    - installed

pipx:
  pkg:
    - installed
    - require:
      - pkg: python3-venv

/home/max/.envs:
  file:
    - directory
    - user: max
    - group: max

jedi-language-server-installed:
  cmd:
    - run
    - name: pipx install jedi-language-server
    - unless: ls /home/max/.local/bin/jedi-language-server
    - runas: max
    - require:
      - pkg: pipx

python3-ipython:
  pkg:
    - installed

ipython-install:
  cmd:
    - run
    - name: update-alternatives --install /usr/bin/ipython ipython /usr/bin/ipython3 60
    - unless: update-alternatives --list ipython | grep "^/usr/bin/ipython3$"
    - require:
      - pkg: python3-ipython

ipython-auto:
  alternatives:
    - auto
    - name: ipython 
    - require:
      - cmd: ipython-install

python3-seaborn:
  pkg:
    - installed

python3-pandas:
  pkg:
    - installed

python3-pip:
  pkg:
    - installed

pip-install:
  cmd:
    - run
    - name: update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 60
    - unless: update-alternatives --list pip | grep "^/usr/bin/pip3$"
    - require:
      - pkg: python3-pip

pip-auto:
  alternatives:
    - auto
    - name: pip 
    - require:
      - cmd: pip-install

statsmodels-installed:
  cmd:
    - run
    - name: pip install statsmodels
    - unless: pip freeze | grep "^statsmodels=="
    - require:
      - alternatives: pip-auto

python3-matplotlib:
  pkg:
    - installed

python3-ipdb:
  pkg:
    - installed

python3-netaddr:
  pkg:
    - installed

yq-installed:
  cmd:
    - run
    - name: snap install yq
    - unless: which yq

jq-installed:
  cmd:
    - run
    - name: snap install jq
    - unless: which jq

glab-cloned:
  git:
    - cloned
    - name: git@github.com:/profclems/glab.git
    - target: /home/max/glab
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

glab-installed:
  cmd:
    - run
    - name: sh /home/max/glab/scripts/install.sh
    - unless: which glab
    - require:
      - git: glab-cloned

black-installed:
  cmd:
    - run
    - name: pipx install black
    - unless: ls /home/max/.local/bin/black
    - runas: max
    - require:
      - pkg: pipx

isort-installed:
  cmd:
    - run
    - name: pipx install isort
    - unless: ls /home/max/.local/bin/isort
    - runas: max
    - require:
      - pkg: pipx

pgformatter:
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
    - require:
      - pkg: neovim

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

go1.4-installed:
  cmd:
    - run
    - name: source /home/max/.gvm/scripts/gvm && gvm install go1.4 -B
    - unless: source /home/max/.gvm/scripts/gvm && which go
    - runas: max
    - require:
      - cmd: gvm-installed
      - pkg: bison
      - pkg: gcc
      - pkg: make


go-installed:
  cmd:
    - run
    - name: source /home/max/.gvm/scripts/gvm && gvm install go1.15.6 && gvm use go1.15.6 --default"
    - unless: source /home/max/.gvm/scripts/gvm && which go && go version | grep "go1.15.6"
    - runas: max
    - require:
      - cmd: go1.4-installed

gopls-installed:
 cmd:
   - run
   - name: source /home/max/.gvm/scripts/gvm && go get golang.org/x/tools/gopls
   - unless: source /home/max/.gvm/scripts/gvm && which gopls
   - runas: max
   - env:
     - GO111MODULUE: on
   - require:
     - cmd: go-installed
     - cmd: ssh-setup

gofumpt-installed:
 cmd:
   - run
   - name: source /home/max/.gvm/scripts/gvm && go get mvdan.cc/gofumpt
   - unless: source /home/max/.gvm/scripts/gvm && which gofumpt
   - runas: max
   - env:
     - GO111MODULUE: on
   - require:
     - cmd: go-installed
     - cmd: ssh-setup

go-delve-cloned:
  git:
    - cloned
    - name: git@github.com:go-delve/delve.git
    - target: /home/max/delve
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

go-delve-installed:
 cmd:
   - run
   - name: source /home/max/.gvm/scripts/gvm && cd /home/max/delve && go install github.com/go-delve/delve/cmd/dlv
   - unless: source /home/max/.gvm/scripts/gvm && which dlv
   - runas: max
   - env:
     - GO111MODULUE: on
   - require:
     - cmd: go-installed
     - cmd: ssh-setup
     - git: go-delve-cloned

antibody:
  pkg.installed:
    - sources:
      - antibody: https://github.com/getantibody/antibody/releases/download/v6.1.1/antibody_6.1.1_linux_amd64.deb

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
    - runas: max

gnome-tweaks:
  pkg:
    - installed

docker-repo:
  pkgrepo:
    - managed
    - name: deb https://download.docker.com/linux/ubuntu focal stable
    - file: /etc/apt/sources.list.d/docker.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - clean_file: True

docker-ce:
  pkg:
    - installed
    - require:
      - pkgrepo: docker-repo

docker-ce-cli:
  pkg:
    - installed
    - require:
      - pkgrepo: docker-repo

containerd.io:
  pkg:
    - installed
    - require:
      - pkgrepo: docker-repo

docker-compose:
  pkg:
    - installed

pgcli:
  pkg:
    - installed

protobuf-compiler:
  pkg:
    - installed

golang-goprotobuf-dev:
  cmd:
    - run
    - name: source /home/max/.gvm/scripts/gvm && go install google.golang.org/protobuf/cmd/protoc-gen-go
    - unless: source /home/max/.gvm/scripts/gvm && which protoc-gen-go
    - runas: max
    - env:
      - GO111MODULUE: on
    - require:
      - cmd: go-installed
      - cmd: ssh-setup

sops-installed:
 cmd:
   - run
   - name: source /home/max/.gvm/scripts/gvm && go get go.mozilla.org/sops/v3/cmd/sops
   - unless: source /home/max/.gvm/scripts/gvm && which sops
   - runas: max
   - env:
     - GO111MODULUE: on
   - require:
     - cmd: go-installed
     - cmd: ssh-setup

iotop:
  pkg:
    - installed

csvtool:
  pkg:
    - installed

gnome-shell-extension-ubuntu-dock:
  pkg:
    - purged

vanilla-gnome-desktop:
  pkg:
    - installed

ubuntu-gnome-desktop:
  pkg:
    - purged

net-tools:
  pkg:
    - installed

idn:
  pkg:
    - installed

helm-repo:
  pkgrepo:
    - managed
    - name: deb https://baltocdn.com/helm/stable/debian/ all main
    - file: /etc/apt/sources.list.d/helm-stable-debian.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://baltocdn.com/helm/signing.asc
    - clean_file: True

helm:
  pkg:
    - installed
    - require:
      - pkgrepo: helm-repo

helm-diff:
  cmd:
    - run
    - name: helm plugin install https://github.com/databus23/helm-diff
    - unless: helm plugin list | grep "diff"
    - runas: max
    - require:
      - pkg: helm
      - pkg: git
      - cmd: ssh-setup

/usr/local/bin/minikube:
  file:
    - managed
    - source: https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    - skip_verify: true
    - mode: 755

/usr/local/bin/skaffold:
  file:
    - managed
    - source: https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
    - skip_verify: true
    - mode: 755

uidmap:
  pkg:
    - installed

docker-ce-rootless-extras:
  pkg:
    - installed
    - require:
      - pkg: uidmap

dockerd-rootless-running:
  cmd:
    - run
    - name: dockerd-rootless-setuptool.sh install
    - unless: systemctl --user status docker.service
    - runas: max
    - env:
      - DBUS_SESSION_BUS_ADDRESS: unix:path=/run/user/1000/bus
      - XDG_RUNTIME_DIR: /run/user/1000
    - require:
      - pkg: docker-ce-rootless-extras

clangd:
  pkg:
    - installed

/usr/local/bin/kind:
  file:
    - managed
    - source: https://kind.sigs.k8s.io/dl/v0.11.1/kind-linux-amd64
    - skip_verify: true
    - mode: 755

/usr/local/bin/k3s:
  file:
    - managed
    - source: https://github.com/k3s-io/k3s/releases/download/v1.21.1%2Bk3s1/k3s
    - skip_verify: true
    - mode: 755

kubernetes-repo:
  pkgrepo:
    - managed
    - name: deb https://apt.kubernetes.io/ kubernetes-xenial main
    - file: /etc/apt/sources.list.d/kubernetes.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
    - clean_file: True

kubectl:
  pkg:
    - installed
    - require:
      - pkgrepo: kubernetes-repo

deadsnakes-ppa:
  pkgrepo.managed:
    - ppa: deadsnakes/ppa

python3.7:
  pkg:
    - installed
    - require:
      - pkgrepo: deadsnakes-ppa

python3.7-venv:
  pkg:
    - installed
    - require:
      - pkgrepo: deadsnakes-ppa

cloudsql-proxy:
  pkg:
    - installed

gcloud-repo:
  pkgrepo:
    - managed
    - name: deb https://packages.cloud.google.com/apt cloud-sdk main
    - file: /etc/apt/sources.list.d/google-cloud-sdk.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
    - clean_file: True

google-cloud-sdk:
  pkg:
    - installed
    - require:
      - pkgrepo: gcloud-repo
