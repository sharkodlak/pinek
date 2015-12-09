phalcon.repo:
  pkgrepo.managed:
    - humanname: Debianiste.org
    - name: deb http://apt.debianiste.org/debian jessie main
    - file: /etc/apt/sources.list.d/phalcon.list
    - keyid: 31F49B93
    - keyserver: pgpkeys.mit.edu
    - refresh_db: true

dotdeb.repo:
  pkgrepo.managed:
    - humanname: Dotdeb
    - name: deb http://packages.dotdeb.org jessie all
    - file: /etc/apt/sources.list.d/dotbeb.list
    - keyid: 89DF5277
    - keyserver: keys.gnupg.net
    - refresh_db: true

setup-www:
  pkg.latest:
    - pkgs:
      - nginx
      - php5-fpm # php7.0-fpm
      - php5-xdebug
      - php5-phalcon
  file.directory:
    - name: /var/log/www
    - user: www-data
    - group: adm
    - mode: 775
    - makedirs: True

nginx:
  module.run:
    - name: service.reload
    - m_name: nginx
  service.running:
    - enable: True

php5-fpm:
  module.run:
    - name: service.restart
    - m_name: php5-fpm
  service.running:
    - enable: True
