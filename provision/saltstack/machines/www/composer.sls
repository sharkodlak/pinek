composer setup:
  file.missing:
    - name: /usr/local/bin/composer
  cmd.run:
    - name: curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    - require:
      - file: composer setup

composer install required dependencies:
  environ.setenv:
    - name: HOME
    - value: /root
    - onchanges:
      - cmd: composer setup
  cmd.run:
    - name: cd /vagrant.root && composer install
