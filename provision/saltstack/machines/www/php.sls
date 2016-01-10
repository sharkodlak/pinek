PHP setup:
  pkg.latest:
    - pkgs:
      - php5-fpm # php7.0-fpm
      - php5-xdebug
      - php5-xsl # needed by theseer/phpdox
  file.directory:
    - name: /var/log/www
    - user: www-data
    - group: adm
    - mode: 775
    - makedirs: True
    - onchanges:
      - pkg: PHP setup

PHP modify logrotate to maintain /var/log/www:
  file.managed:
    - name: /etc/logrotate.d/php5-fpm
    - source: salt://filesystem/etc/logrotate.d/php5-fpm
    - onchanges:
      - file: PHP setup

PHP setup www.conf:
  file.patch:
    - name: /etc/php5/fpm/pool.d/www.conf
    - source: salt://filesystem/etc/php5/fpm/pool.d/www.conf.patch
    - hash: md5=64f9e56ef82f9f29a07d6ea71eb985dc

PHP setup xdebug:
  file.managed:
    - name: /etc/php5/mods-available/xdebug.ini
    - source: salt://filesystem/etc/php5/mods-available/xdebug.ini

php5-fpm:
  module.run:
    - name: service.reload
    - m_name: php5-fpm
    - onchanges:
      - file: PHP setup www.conf
  service.running:
    - enable: True
