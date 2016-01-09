composer install:
  file.missing:
    - name: /usr/local/bin/composer
  cmd.run:
    - name: curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
    - require:
      - file: /usr/local/bin/composer

composer install dependencies:
  environ.setenv:
    - name: HOME
    - value: /root
  cmd.run:
    - name: cd /vagrant.root && composer install
