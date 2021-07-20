base:
  '*':
    - default
  'worky':
    - worky
  'yubikey':
    - match: grain
    - yubikey
  'not G@yubikey':
    - match: compound
    - no-yubikey
  'roles:server':
    - match: grain
    - server
