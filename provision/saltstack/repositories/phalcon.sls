Phalcon repo:
  pkgrepo.managed:
    - humanname: Debianiste.org
    - name: deb http://apt.debianiste.org/debian jessie main
    - file: /etc/apt/sources.list.d/phalcon.list
    - keyid: 31F49B93
    - keyserver: pgpkeys.mit.edu
    - refresh_db: true
    - require_in: php5-phalcon
