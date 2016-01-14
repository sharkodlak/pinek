base:
  '*':
    - timezone
    - locales
    - enhancements
  'os:Debian':
    - match: grain
    - shell
  'roles:ci':
    - match: grain
    - ci
  'roles:db':
    - match: grain
    - db
  'roles:www':
    - match: grain
    - www
