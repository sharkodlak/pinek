setup-www:
  pkg.installed:
    - pkgs:
      - nginx
      - php5-fpm
      - php5-xdebug
      - php5-phalcon
