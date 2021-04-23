include:
  - default

zoom-installed:
  pkg:
    - installed
    - sources:
      - zoom: https://zoom.us/client/latest/zoom_amd64.deb 

zoom-latest:
  pkg:
    - latest
    - name: zoom
    - require:
      - pkg: zoom-installed

scdaemon:
  pkg:
    - installed

pcscd-installed:
  pkg:
    - installed
    - name: pcscd

pcscd-enabled:
  service:
    - enabled
    - name: pcscd
    - require:
      - pkg: pcscd-installed

pcscd-running:
  service:
    - running
    - name: pcscd
    - require:
      - service: pcscd-enabled

SSH_AUTH_SOCK:
  environ:
    - setenv
    - value: /run/user/1000/gnupg/S.gpg-agent.ssh

ssh-setup:
  cmd:
    - run
    - name: ssh-add -L
    - unless: exit 1
    - require:
      - service: pcscd-running
      - pkg: scdaemon
      - environ: SSH_AUTH_SOCK

stow-gitwork:
  cmd:
    - run
    - name: stow -d /home/max/dotfiles -S gitwork
    - require:
      - pkg: stow
      - git: dotfiles
      - cmd: stow-git

pipeline-cloned:
  git:
    - cloned
    - name: git@gitlab.com:censys/pipeline.git 
    - target: /home/max/pipeline
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup
