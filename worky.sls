include:
  - default

zoom-installed:
  pkg:
    - installed
    - sources:
      - zoom: https://zoom.us/client/latest/zoom_amd64.deb 

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

nvidia-ppa:
  pkgrepo.managed:
    - ppa: graphics-drivers/ppa

whois:
  pkg:
    - installed

gcloud-auth:
  cmd:
    - run
    - name: gcloud auth login
    - unless: gcloud auth list | grep "maxmzkr@censys.io"
    - runas: max
    - require:
      - pkg: google-cloud-sdk

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

kubectl-credentials:
  cmd:
    - run
    - name: gcloud container clusters get-credentials censys-internal --zone us-central1-a --project censys-internal
    - unless: kubectl config current-context
    - runas: max
    - require:
      - pkg: kubectl
      - cmd: gcloud-auth

docker-gcr:
  cmd:
    - run
    - name: echo "y" | gcloud auth configure-docker 
    - unless: grep "gcr" /home/max/.docker/config.json
    - runas: max
    - require:
      - pkg: docker-ce
      - pkg: gcloud
