include:
  - repositories.phalcon

setup php:
  pkg.latest:
    - pkgs:
      - php5-fpm # php7.0-fpm
      - php5-xdebug
      - php5-xsl
  file.directory:
    - name: /var/log/www
    - user: www-data
    - group: adm
    - mode: 775
    - makedirs: True

/etc/php5/fpm/pool.d/www.conf:
  file.patch:
    - source: salt://filesystem/etc/php5/fpm/pool.d/www.conf.patch
    - hash: md5=64f9e56ef82f9f29a07d6ea71eb985dc

/etc/php5/mods-available/xdebug.ini:
  file.managed:
    - source: salt://filesystem/etc/php5/mods-available/xdebug.ini

/etc/logrotate.d/php5-fpm:
  file.managed:
    - source: salt://filesystem/etc/logrotate.d/php5-fpm

php5-fpm:
  module.run:
    - name: service.reload
    - m_name: php5-fpm
  service.running:
    - enable: True
