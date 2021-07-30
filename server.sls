/etc/ssh/sshd_config.d/99-no-password.conf:
  file:
    - managed
    - contents: |
       ChallengeResponseAuthentication no
       PasswordAuthentication no
       UsePAM no
       PermitRootLogin no
       PermitRootLogin prohibit-password

openssh-server:
  pkg:
    - installed
    - require:
      - file: /etc/ssh/sshd_config.d/99-no-password.conf

sshkeys:
  ssh_auth:
    - manage
    - user: max
    - ssh_keys:
      - AAAAB3NzaC1yc2EAAAADAQABAAACAQDKgvuH7YbIHVTT98HkXdVfspxhVkQo6jauuSW/5Dj6fC37AOVDGn90f62QfmphRhevgn53gjceo1cFi5sy8YaMs80zw5pGJofJ1sL82ipvMRgqFI3Z8Ykwh1xuFtB4FNGAM2Ew9nw9TmOKlOcY1RY0yThFtizaAvaUU26xC1LezMRoBX9fK1Fe+woCBr9uyTEczGkgJHa9C7LwVhWsYYj4Fx16Ub1iCAFPOm61b65gyaBE6g7P0fU1xiXfzNSZmnvLJF9wlcAmxwBjzqu3S9Ynhx8uSeIjCrC9/0ECFb6LHZ8ClihncL8qk+/vWGAEdAH0aBDz1/Lp1YGWYjEH8Xcd/LtNY8pMqwA7UUmWz3N9//iMTVMSGATNBAGSmfi4WoemO1Qewd3KFfqHpNvxJMLhU+5R/qJTvQHZgkiEm7r2CGwY4puk3ouHND01q5ZywaragA0spnc0ef0AU+ZyJOfe32O1VBomQbEAGv0J4VBV0X4UrU1xyjmznOYv2aqdEFDpJIzu7wzZd1IJkJlBwj5PMSc/ypWDnFJWb+xmH7gQ8PPUUoM56+UKoWi1/njLf0Z+VqbiTwnJuNSzup9esCcxS4HlMjDnZxR9jnft4FCvtvq8QJF4Sk3us632Z6UTjXvHN2JZQJBIBvc6QWL25FvHLdpr7ExotMMochUjmx9vLQ== (none)
      - AAAAB3NzaC1yc2EAAAADAQABAAACAQC1iaKZ1EFzSic/dd+DK5jzEsr2Mk3/MzsbdhQAUBIirZnOMrtCx+lkwOAxotdNjhFPHbSgi3wUfACiXlFgHayn4Ca2nyjF5eJN90upHRiD+Br+RGc5fQGjnIxo4Kk/p2hWiO7OEC6od0TqTPp547zBKU1Qfe37oXnwRTDbuba+xj/Cahi6ywXkMKvc6NAi7lCc/luwD+8lJ1eD1LBoWFOL9fF+bLKPMcg7wN1QV6RrMKXW3ga1eSQReUVOMpgdMh1M32OIAad8U8LpZTjNql6aAIN/4N44M9r8Lof4WcgDjAN6BNpPasgSR6gktgE0EPxKr+7czR4lnxweLE3wGWPk2pQKqEcnD3expA+mgLyixvk/eX/YXTdZ1FjlPwJNVfS/9YJf/WvEZVC+JT0vKzDYiJBz7E/Huq8liQJsO7LRsg623oWJAuvw8lWruE+D8DZdpCkR5x57k7hFe5a9MnH6+M1I/3tmpNr30IS3Hgw/+mqT1zE6kEJzOLypGHSQTbe46CR1mFP49UGxwqwoouJZRt0MKcgyE/yDw2K8spM9OECkvj7lwUqewyHBnGlj6ugRWsrtXZWtAYrrgYb8p+oEUVO1lipoHQRVDRy31XDMZocmDOIhnx1FpotoACPv6uq7b9oXpigYlicsO7KeomEVtbrM1zBtFFoKo4y4lqmb6Q== cardno:000612567609

virtualgl:
  pkg:
    - installed
    - sources:
      - virtualgl: https://pilotfiber.dl.sourceforge.net/project/virtualgl/2.6.90%20%283.0beta1%29/virtualgl_2.6.90_amd64.deb 
