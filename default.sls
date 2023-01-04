{%- set gh_token = salt['cmd.shell']('yq eval \'."github.com".oauth_token\' /home/max/.config/gh/hosts.yml') -%}
{% if grains['os'] != 'Fedora' %}
python-is-python3:
  pkg:
    - installed
{% endif %}

pipx:
  pkg:
    - installed

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


{% if grains['os'] == 'Fedora' %}
snapd:
  pkg:
    - installed

/snap:
  file:
    - symlink
    - target: /var/lib/snapd/snap
{% endif %}

yq:
  cmd:
    - run
    - name: snap install yq
    - unless: which yq
{% if grains['os'] == 'Fedora' %}
    - require:
      - pkg: snapd
      - file: /snap
{% endif %}

old-jq-snap:
  cmd:
    - run
    - name: snap remove jq
    - unless: "! snap list jq && true"
{% if grains['os'] == 'Fedora' %}
    - require:
      - pkg: snapd
      - file: /snap
{% endif %}

jq-core20:
  cmd:
    - run
    - name: snap install --edge jq-core20
    - unless: which jq-core20
    - require:
      - cmd: old-jq-snap
{% if grains['os'] == 'Fedora' %}
    - require:
      - pkg: snapd
      - file: /snap
{% endif %}

jq-alias:
  cmd:
    - run
    - name: snap alias jq-core20.jq jq
    - unless: which jq
    - require:
      - cmd: jq-core20
{% if grains['os'] == 'Fedora' %}
    - require:
      - pkg: snapd
      - file: /snap
{% endif %}

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

{#
pgformatter:
  pkg:
    - installed
#}

neovim-repo:
  pkgrepo:
    - managed
{% if grains['os'] == 'Fedora' %}
    - name: neovim-nightly
    - baseurl: https://download.copr.fedorainfracloud.org/results/agriffis/neovim-nightly/fedora-$releasever-$basearch/
    - gpgcheck: 1
    - gpgkey: https://download.copr.fedorainfracloud.org/results/agriffis/neovim-nightly/pubkey.gpg 
{% else %}
    - ppa: neovim-ppa/unstable
{% endif %}

neovim:
  pkg:
    - installed 
    - require:
      - pkgrepo: neovim-repo

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
  
{% if grains['os'] != 'Fedora' %}
git-repo:
  pkgrepo.managed:
    - ppa: git-core/ppa
{% endif %}

git:
  pkg:
    - installed
{% if grains['os'] != 'Fedora' %}
    - require:
      - pkgrepo: git-repo
{% endif %}

/home/max/.cache/nvim/back:
  file:
    - directory
    - user: max
    - group: max
    - makedirs: True

/home/max/.cache/nvim/swap:
  file:
    - directory
    - user: max
    - group: max
    - makedirs: True

/home/max/.cache/nvim/undo:
  file:
    - directory
    - user: max
    - group: max
    - makedirs: True

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
    - name: nvim '+call dein#install()' '+qa!'
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

{% if grains['os'] != 'Fedora' %}
apt-file:
  pkg:
    - installed
{% endif %}

stow:
  pkg:
    - installed

stow-git:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S git
    - runas: max
    - require:
      - pkg: stow
      - git: dotfiles

stow-dconf-prep:
  cmd:
    - run
    - name: rm /home/max/.config/dconf/user
    - unless: test -h /home/max/.config/dconf/user
    - runas: max
    - require:
      - pkg: stow
      - git: dotfiles

stow-dconf:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S dconf
    - runas: max
    - require:
      - pkg: stow
      - git: dotfiles
      - cmd: stow-dconf-prep

stow-neovim:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S neovim
    - runas: max
    - require:
      - pkg: neovim
      - git: dotfiles

xclip:
  pkg:
    - installed

{% if grains['os'] != 'Fedora' %}
dconf-cli:
  pkg:
    - installed
{% endif %}

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
{% if grains['os'] != 'Fedora' %}
      - pkg: dconf-cli
{% endif %}
      - git: solarized-cloned

zsh:
  pkg:
    - installed

stow-zsh:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S zsh
    - runas: max
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
    - name: source /home/max/.gvm/scripts/gvm && gvm use go1.4 && gvm install go1.18 && gvm use go1.18 --default && gvm use go1.18
    - unless: source /home/max/.gvm/scripts/gvm && which go && go version | grep "go1.18"
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

anitbody:
  gh:
    - pkg_installed
    - sources:
      - repo: getantibody/antibody
        pattern: "*amd64.rpm"


antibody:
  gh:
    - pkg_installed
    - api_key: {{ gh_token }}
    - sources:
      - antibody:
          repo: getantibody/antibody
{% if grains['os'] == 'Fedora' %}
          pattern: "*amd64.rpm"
{% else %}
          pattern: "*amd64.deb"
{% endif %}

tmux-plugins-cloned:
  git:
    - cloned
    - name: git@github.com:tmux-plugins/tpm.git
    - target: /home/max/.tmux/plugins/tpm
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

stow-tmux:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S tmux
    - runas: max
    - require:
      - pkg: stow
      - git: dotfiles
      - git: tmux-plugins-cloned

tmux-cloned:
  git:
    - cloned
    - name: git@github.com:tmux/tmux.git
    - target: /home/max/tmux
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup
      - cmd: stow-tmux

automake:
  pkg:
    - installed

libevent-dev:
  pkg:
    - installed
{% if grains['os'] == 'Fedora' %}
    - name: libevent-devel
{% else %}
    - name: libevent-dev
{% endif %}

libncurses-dev:
  pkg:
    - installed
{% if grains['os'] == 'Fedora' %}
    - name: ncurses-devel
{% else %}
    - name: libncurses-dev
{% endif %}

tmux-remove-default:
  pkg:
    - removed
    - name: tmux

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
      - pkg: tmux-remove-default

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
{% if grains['os'] == 'Fedora' %}
    - name: docker-ce
    - baseurl: https://download.docker.com/linux/fedora/$releasever/$basearch/stable 
    - gpgcheck: 1
    - gpgkey: https://download.docker.com/linux/fedora/gpg
{% else %}
    - name: deb https://download.docker.com/linux/ubuntu focal stable
    - file: /etc/apt/sources.list.d/docker.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://download.docker.com/linux/ubuntu/gpg
    - clean_file: True
{% endif %}

docker-ce:
  pkg:
    - installed
    - require:
      - pkgrepo: docker-repo

docker-enabled:
  service:
    - enabled
    - name: docker
    - require:
      - pkg: docker-ce

docker-ce-running:
  service:
    - running
    - name: docker
    - require:
      - service: docker-enabled

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

protobuf-devel:
  pkg:
    - installed

{#
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
#}

sops:
  gh:
    - pkg_installed
    - sources:
      - sops:
        - repo: mozilla/sops
{% if grains['os'] == 'Fedora' %}
        - pattern: "*x86_64.rpm"
{% else %}
        - pattern: "*.deb"
{% endif %}

iotop:
  pkg:
    - installed

csvtool:
  pkg:
    - installed
{% if grains['os'] == 'Fedora' %}
    - name: ocaml-csv
{% else %}
    - name: csvtool
{% endif %}

gnome-shell-extension-ubuntu-dock:
  pkg:
    - purged

{% if grains['os'] != 'Fedora' %}
vanilla-gnome-desktop:
  pkg:
    - installed
{% endif %}

ubuntu-gnome-desktop:
  pkg:
    - purged

net-tools:
  pkg:
    - installed

idn:
  pkg:
    - installed
{% if grains['os'] == 'Fedora' %}
    - name: libidn
{% else %}
    - name: idn
{% endif %}

{% if grains['os'] != 'Fedora' %}
helm-repo:
  pkgrepo:
    - managed
    - name: deb https://baltocdn.com/helm/stable/debian/ all main
    - file: /etc/apt/sources.list.d/helm-stable-debian.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://baltocdn.com/helm/signing.asc
    - clean_file: True
{% endif %}

helm:
{% if grains['os'] == 'Fedora' %}
  cmd:
    - run
    - name: snap install helm --channel=3.6/stable --classic
    - unless: which helm
    - require:
      - pkg: snapd
      - file: /snap
{% else %}
  pkg:
    - installed
    - require:
      - pkgrepo: helm-repo
{% endif %}

helm-diff:
  cmd:
    - run
    - name: helm plugin install https://github.com/databus23/helm-diff
    - unless: helm plugin list | grep "diff"
    - runas: max
    - require:
{% if grains['os'] == 'Fedora' %}
      - cmd: helm
{% else %}
      - pkg: helm
{% endif %}
      - pkg: git
      - cmd: ssh-setup

helm-secrets:
  cmd:
    - run
    - name: helm plugin install https://github.com/jkroepke/helm-secrets
    - unless: helm plugin list | grep "secrets"
    - runas: max
    - require:
{% if grains['os'] == 'Fedora' %}
      - cmd: helm
{% else %}
      - pkg: helm
{% endif %}
      - pkg: git
      - cmd: ssh-setup

helm-gcs:
  cmd:
    - run
    - name: helm plugin install https://github.com/hayorov/helm-gcs.git
    - unless: helm plugin list | grep "secrets"
    - runas: max
    - require:
{% if grains['os'] == 'Fedora' %}
      - cmd: helm
{% else %}
      - pkg: helm
{% endif %}
      - pkg: git
      - cmd: ssh-setup

minikube:
  pkg:
    - installed
    - sources:
{% if grains['os'] == 'Fedora' %}
      - minikube: https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
{% else %}
      - minikube: https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
{% endif %}

{#
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
#}

clangd:
  pkg:
    - installed
{% if grains['os'] == 'Fedora' %}
    - name: clang-tools-extra
{% else %}
    - name: clangd
{% endif %}

/home/max/.bin:
  file:
    - directory
    - user: max
    - group: max

/home/max/.kbenv:
  file:
    - directory
    - user: max
    - group: max

kbenv-archive:
  gh:
    - archive_extracted
    - name: /home/max/.kbenv
    - repo: little-angry-clouds/kubernetes-binaries-managers
    - api_key: {{ gh_token }}
    - pattern: kbenv-linux-amd64.tar.gz
    - user: max
    - group: max
    - skip_verify: true
    - enforce_toplevel: false
    - require:
      - file: /home/max/.kbenv

/home/max/.local/bin/kbenv:
  file:
    - managed
    - source: /home/max/.kbenv/kbenv-linux-amd64
    - user: max
    - group: max
    - mode: 755
    - require:
      - archive: kbenv-archive

/home/max/.local/bin/kubectl:
  file:
    - managed
    - source: /home/max/.kbenv/kubectl-wrapper-linux-amd64
    - user: max
    - group: max
    - mode: 755
    - require:
      - archive: kbenv-archive

kbenv:
  cmd:
    - run
    - name: echo "noop"
    - require:
      - file: /home/max/.local/bin/kbenv
      - file: /home/max/.local/bin/kubectl
      - file: /home/max/.bin

kubectl-1.19.4:
  cmd:
    - run
    - name: /home/max/.local/bin/kbenv install 1.19.4
    - unless: /home/max/.local/bin/kbenv list local | grep "1.19.4"
    # - require:
    #   - cmd: kbenv

zlib-devel:
  pkg:
    - installed

openssl-devel:
  pkg:
    - installed

{% if grains['os'] == 'Fedora' %}
python3.7-tar:
  archive:
    - extracted
    - name: /home/max/.python3.7.11
    - source: https://www.python.org/ftp/python/3.7.11/Python-3.7.11.tgz  
    - user: max
    - group: max
    - skip_verify: true

python3.7:
  cmd:
    - run
    - name: cd /home/max/.python3.7.11/Python-3.7.11 && ./configure --enable-optimizations && make altinstall
    - unless: which python3.7
    - require:
      - archive: python3.7-tar
      - pkg: zlib-devel
      - pkg: openssl-devel

python3.7-pip:
  cmd:
    - run
    - name: python3.7 -m ensurepip
    - runas: max
    - require:
      - cmd: python3.7
{% else %}
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
{% endif %}


cloud_sql_proxy:
  gh:
    - file_managed
    - name: /home/max/.local/bin/cloud_sql_proxy
    - repo: GoogleCloudPlatform/cloudsql-proxy
    - pattern: "*linux.amd64"
    - version: 1.33.2
    - api_key: {{ gh_token }}
    - link_source: body
    - skip_verify: true
    - mode: 755

gcloud-repo:
  pkgrepo:
    - managed
{% if grains['os'] == 'Fedora' %}
    - name: google-cloud-sdk
    - baseurl: https://packages.cloud.google.com/yum/repos/cloud-sdk-el7-x86_64
    - gpgcheck: 1
    - gpgkey: https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    - repo_gpgcheck: 0
{% else %}
    - name: deb https://packages.cloud.google.com/apt cloud-sdk main
    - file: /etc/apt/sources.list.d/google-cloud-sdk.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://packages.cloud.google.com/apt/doc/apt-key.gpg
    - clean_file: True
{% endif %}

google-cloud-sdk:
  pkg:
    - installed
    - require:
      - pkgrepo: gcloud-repo

psql:
  pkg:
    - installed
{% if grains['os'] == 'Fedora' %}
    - name: postgresql
{% else %}
    - name: postgresql-client-12
{% endif %}

tfenv-repo:
  git:
    - cloned
    - name: https://github.com/tfutils/tfenv.git
    - target: /home/max/tfenv
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

/home/max/.local/bin/tfenv:
  file:
    - symlink
    - target: /home/max/tfenv/bin/tfenv

/home/max/.local/bin/terraform:
  file:
    - symlink
    - target: /home/max/tfenv/bin/terraform

{#
podman-repo:
  pkgrepo:
    - managed
    - name: deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/testing/xUbuntu_{{ salt['cmd.run']("lsb_release -rs") }}/ /
    - file: /etc/apt/sources.list.d/devel:kubic:libcontainers:testing.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/testing/xUbuntu_{{ salt['cmd.run']("lsb_release -rs") }}/Release.key
    - clean_file: True

podman:
  pkg:
    - installed
    - require:
      - pkgrepo: podman-repo
#}

chrome-repo:
  pkgrepo:
    - managed
{% if grains['os'] == 'Fedora' %}
    - name: google-chrome
    - baseurl: http://dl.google.com/linux/chrome/rpm/stable/x86_64
    - gpgcheck: 1
    - gpgkey: https://dl.google.com/linux/linux_signing_key.pub
{% else %}
    - name: deb http://dl.google.com/linux/chrome/deb/ stable main
    - file: /etc/apt/sources.list.d/google-chrome.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://dl.google.com/linux/linux_signing_key.pub
    - clean_file: True
{% endif %}

google-chrome-stable:
  pkg:
    - installed
    - require:
      - pkgrepo: chrome-repo

{#
xpra-repo:
  pkgrepo:
    - managed
    - name: deb https://xpra.org/ {{ salt['cmd.run']("lsb_release -cs") }} main
    - file: /etc/apt/sources.list.d/xpra.list
    - architectures: amd64
    - gpgcheck: 1
    - key_url: https://xpra.org/gpg.asc
    - clean_file: True

xpra:
  pkg:
    - installed
    - requires:
      - pkg: xpra-repo
#}

gparted:
  pkg:
    - installed

kompose:
  cmd:
    - run
    - name: snap install kompose
    - unless: which kompose
{% if grains['os'] == 'Fedora' %}
    - require:
      - pkg: snapd
      - file: /snap
{% endif %}

mesa-utils:
  pkg:
    - installed

openjdk-16-jre-headless:
  pkg:
    - installed

helm-bitnami-repo:
  cmd:
    - run
    - name: helm repo add bitnami https://charts.bitnami.com/bitnami
    - unless: helm repo list | grep bitnami
    - runas: max
    - require:
      - pkg: helm

subversion:
  pkg:
    - installed

docker-group:
  group:
    - present
    - name: docker
    - members:
      - max

nvm:
  cmd:
    - run
    - name: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
    - unless: ls /home/max/.nvm/nvm.sh
    - runas: max

npm:
  cmd:
    - run
    - name: source /home/max/.nvm/nvm.sh && nvm install node --default
    - unless: source /home/max/.nvm/nvm.sh && which npm
    - runas: max
    - require:
      - cmd: nvm

ng:
  cmd:
    - run
    - name: source /home/max/.nvm/nvm.sh && npm install @angular/cli 
    - unless: source /home/max/.nvm/nvm.sh && npm ls ng
    - runas: max
    - require:
      - cmd: npm

systemd-resolved-disabled:
  service:
    - dead
    - name: systemd-resolved
    - enable: False

dnsmasq:
  pkg:
    - installed

/etc/dnsmasq.conf:
  file:
    - managed
    - contents: |
        conf-dir=/etc/dnsmasq.d/,*.conf

network-manager-dns:
  file:
    - blockreplace
    - name: /etc/NetworkManager/NetworkManager.conf
    - insert_after_match: \[main\]
    - marker_start: "#-- start managed zone - dns --"
    - marker_end: "#-- end managed zone - dns --"
    - content: |
        dns=dnsmasq

NetworkManager.service:
  service:
    - running
    - enable: True
    - watch:
      - pkg: dnsmasq
      - file: /etc/dnsmasq.conf
      - file: network-manager-dns
      - service: resolvconf.service
      - service: systemd-resolved-disabled

resolvconf.service:
  service:
    - dead
    - enable: False

ifupdown:
  pkg:
    - installed

xrandr:
  pkg:
    - installed

openssl:
  pkg:
    - installed

uuid:
  pkg:
    - installed

telnet:
  pkg:
    - installed

exa:
  pkg:
    - installed

jwt-cli:
  gh:
    - archive_binary
    - name: /home/max/.local/bin/jwt
    - repo: mike-engel/jwt-cli
    - pattern: jwt-linux.tar.gz
    - file_name: jwt
    - api_key: {{ gh_token }}
    - user: max
    - group: max
    - mode: 755
 
pulseaudio-utils:
  pkg:
    - installed
 
terraformer:
  gh:
    - binary
    - repo: GoogleCloudPlatform/terraformer
    - name: /home/max/.local/bin/terraformer
    - pattern: terraformer-google-linux-amd64
    - api_key: {{ gh_token }}
    - user: max
    - group: max
    - mode: 755

google-cloud-sdk-pubsub-emulator:
  pkg:
    - installed

google-cloud-pubsub:
  cmd:
    - run
    - name: source /home/max/.gvm/scripts/gvm && go get cloud.google.com/go/pubsub
    - unless: source /home/max/.gvm/scripts/gvm && which gopls
    - runas: max
    - env:
      - GO111MODULUE: on
    - require:
      - cmd: go-installed
      - cmd: ssh-setup

python-pubsub:
  git:
    - cloned
    - name: git@github.com:/googleapis/python-pubsub.git
    - target: /home/max/python-pubsub
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

maven:
  pkg:
    - installed

/opt/Postman:
  file:
    - directory

postman:
  archive:
    - extracted
    - name: /opt
    - source: https://dl.pstmn.io/download/latest/linux64
    - archive_format: tar
    - skip_verify: true
    - require:
      - file: /opt/Postman

/usr/local/bin/postman:
  file:
    - symlink
    - target: /opt/Postman/Postman
    - require:
      - archive: postman

/usr/local/share/applications/postman.desktop:
  file:
    - managed
    - contents: |
        [Desktop Entry]
        Name=Postman
        Exec=/usr/local/bin/postman
        StartupNotify=true
        Terminal=false
        Icon=/opt/Postman/app/icons/icon_128x128.png
        Type=Application
        Categories=Network;
    - require:
      - file: /usr/local/bin/postman

grpcurl:
  gh:
    - archive_binary
    - name: /home/max/.local/bin/grpcurl
    - repo: fullstorydev/grpcurl
    - pattern: grpcurl_*_linux_x86_64.tar.gz
    - file_name: grpcurl
    - api_key: {{ gh_token }}
    - user: max
    - group: max
    - mode: 755

autorandr:
  pkg:
    - installed

stylua:
  gh:
    - archive_binary
    - name: /home/max/.local/bin/stylua
    - repo: JohnnyMorganz/StyLua
    - pattern: 'stylua-linux.zip'
    - api_key: {{ gh_token }}
    - user: max
    - group: max
    - mode: 755

wrench:
  gh:
    - binary
    - name: /home/max/.local/bin/wrench
    - repo: cloudspannerecosystem/wrench
    - pattern: wrench_linux_amd64
    - api_key: {{ gh_token }}
    - user: max
    - group: max
    - mode: 755

spanner-cli:
  cmd:
    - run
    - name: source /home/max/.gvm/scripts/gvm && go install github.com/cloudspannerecosystem/spanner-cli@latest
    - unless: source /home/max/.gvm/scripts/gvm && which spanner-cli
    - runas: max
    - env:
      - GO111MODULUE: on
    - require:
      - cmd: go-installed
      - cmd: ssh-setup

sqlparse:
  cmd:
    - run
    - name: pipx install sqlparse
    - unless: ls /home/max/.local/bin/sqlparse
    - runas: max
    - require:
      - pkg: pipx

poetry:
  pkg:
    - installed

xmlsec1-devel:
  pkg:
    - installed

libtool-ltdl-devel:
  pkg:
     - installed

mysql-devel:
  pkg:
    - installed

grim:
  pkg:
    - installed

slurp:
  pkg:
    - installed

bw:
  cmd:
    - run
    - name: snap install bw
    - unless: "! snap list bw && true"
{% if grains['os'] == 'Fedora' %}
    - require:
      - pkg: snapd
      - file: /snap
{% endif %}

kafka-tar:
  archive:
    - extracted
    - name: /home/max/.kafka
    - source: https://downloads.apache.org/kafka/3.3.1/kafka_2.13-3.3.1.tgz
    - user: max
    - group: max
    - skip_verify: true

jd:
  gh:
    - file_managed
    - name: /home/max/.local/bin/jd
    - repo: josephburnett/jd
    - pattern: jd-amd64-linux
    - version: v1.6.1
    - api_key: {{ gh_token }}
    - skip_verify: true
    - mode: 755
