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

pcscd-installed:
  pkg:
    - installed
{% if grains['os'] == 'Fedora' %}
    - name: pcsc-lite
{% else %}
    - name: pcscd
{% endif %}

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

{% if grains['os'] != 'Fedora' %}
scdaemon:
  pkg:
    - installed
{% endif %}

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
{% if grains['os'] != 'Fedora' %}
      - pkg: scdaemon
{% endif %}
      - environ: SSH_AUTH_SOCK
