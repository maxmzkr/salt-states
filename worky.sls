include:
  - default

zoom-installed:
  pkg:
    - installed
    - sources:
      - zoom: https://zoom.us/client/latest/zoom_amd64.deb 

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
    - name: echo ""
    - unless: echo ""
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

discover-cloned:
  git:
    - cloned
    - name: git@gitlab.com:censys/discover.git 
    - target: /home/max/discover
    - user: max
    - require:
      - pkg: git
      - cmd: ssh-setup

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

nvidia-ppa:
  pkgrepo.managed:
    - ppa: graphics-drivers/ppa

whois:
  pkg:
    - installed

yubikey-manager:
  pkg:
    - installed

/home/max/yubikey-touch-detector:
  archive:
    - extracted
    - source: https://github.com/maximbaz/yubikey-touch-detector/releases/download/1.9.0/yubikey-touch-detector-1.9.0-linux64.tar.gz
    - skip_verify: true
    - user: max
    - group: max

/home/max/.config/systemd/user/yubikey-touch-detector.socket:
  file:
    - managed
    - source: /home/max/yubikey-touch-detector/yubikey-touch-detector-1.9.0-linux64/yubikey-touch-detector.socket
    - skip_verify: true
    - user: max
    - group: max
    - makedirs: true
    - require:
      - archive: /home/max/yubikey-touch-detector

/home/max/.config/systemd/user/yubikey-touch-detector.service:
  file:
    - managed
    - source: /home/max/yubikey-touch-detector/yubikey-touch-detector-1.9.0-linux64/yubikey-touch-detector.service
    - skip_verify: true
    - user: max
    - group: max
    - makedirs: true
    - require:
      - archive: /home/max/yubikey-touch-detector

/home/max/.config/yubikey-touch-detector/service.conf:
  file:
    - managed
    - contents: |
        YUBIKEY_TOUCH_DETECTOR_LIBNOTIFY=true
        YUBIKEY_TOUCH_DETECTOR_VERBOSE=true
    - user: max
    - group: max
    - makedirs: true
    - require:
      - archive: /home/max/yubikey-touch-detector

/usr/bin/yubikey-touch-detector:
  file:
    - managed
    - source: /home/max/yubikey-touch-detector/yubikey-touch-detector-1.9.0-linux64/yubikey-touch-detector
    - skip_verify: true
    - mode: 755
    - require:
      - archive: /home/max/yubikey-touch-detector

yubikey-touch-detector-enabled:
  cmd:
    - run
    - name: systemctl --user enable yubikey-touch-detector
    - unless: systemctl --user is-enabled yubikey-touch-detector
    - runas: max
    - env:
      - DBUS_SESSION_BUS_ADDRESS: unix:path=/run/user/1000/bus
    - require:
      - file: /home/max/.config/systemd/user/yubikey-touch-detector.socket
      - file: /home/max/.config/systemd/user/yubikey-touch-detector.service
      - file: /usr/bin/yubikey-touch-detector
      - file: /home/max/.config/yubikey-touch-detector/service.conf

yubikey-touch-detector-running:
  cmd:
    - wait
    - name: systemctl --user restart yubikey-touch-detector
    - runas: max
    - env:
      - DBUS_SESSION_BUS_ADDRESS: unix:path=/run/user/1000/bus
    - watch:
      - cmd: yubikey-touch-detector-enabled
      - file: /home/max/.config/systemd/user/yubikey-touch-detector.socket
      - file: /home/max/.config/systemd/user/yubikey-touch-detector.service
      - file: /home/max/.config/yubikey-touch-detector/service.conf

cloudsql-proxy:
  pkg:
    - installed

google-cloud-sdk-installed:
  cmd:
    - run
    - name: snap install google-cloud-sdk --classic
    - unless: which gcloud

gcloud-auth:
  cmd:
    - run
    - name: gcloud auth login
    - unless: gcloud auth list | grep "maxmzkr@censys.io"
    - runas: max
    - require:
      - cmd: google-cloud-sdk-installed

gcloud-project:
  cmd:
    - run
    - name: gcloud config set project censys-internal
    - unless: gcloud config get-value project | grep -v "unset"
    - runas: max
    - require:
      - cmd: gcloud-auth

gcloud-zone:
  cmd:
    - run
    - name: gcloud config set compute/zone us-central1-a
    - unless: gcloud config get-value compute/zone | grep -v "unset"
    - runas: max
    - require:
      - cmd: gcloud-auth

gcloud-app-default:
  cmd:
    - run
    - name: gcloud auth application-default login
    - unless: gcloud auth application-default print-access-token > /dev/null
    - runas: max
    - require:
      - cmd: gcloud-auth

kubectl-installed:
  cmd:
    - run
    - name: snap install kubectl --classic
    - unless: which kubectl

kubectl-credentials:
  cmd:
    - run
    - name: gcloud container clusters get-credentials censys-internal --zone us-central1-a --project censys-internal
    - unless: kubectl config current-context
    - runas: max
    - require:
      - cmd: kubectl-installed
      - cmd: gcloud-auth

docker-gcr:
  cmd:
    - run
    - name: echo "y" | gcloud auth configure-docker 
    - unless: grep "gcr" /home/max/.docker/config.json
    - runas: max
    - require:
      - pkg: docker-ce
      - cmd: google-cloud-sdk-installed
