base:
  '*':
    - default
  'worky':
    - worky
    - yubikey
  'not worky':
    - match: compound
    - no-yubikey
  'roles:server':
    - match: grain
    - server
