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
      - environ: SSH_AUTH_SOCK
