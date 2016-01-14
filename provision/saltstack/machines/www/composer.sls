composer setup:
  file.missing:
    - name: /usr/local/bin/composer
  environ.setenv:
    - name: HOME
    - value: /root
    - require:
      - file: composer setup
  cmd.run:
    - names:
      - curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
      - cd /vagrant.root && composer install
    - require:
      - environ: composer setup
