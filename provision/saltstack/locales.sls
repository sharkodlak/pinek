setup locales:
  file.managed:
    - name: /etc/locale.gen
    - source: salt://filesystem/etc/locale.gen
    - user: root
    - group: root
    - mode: 644

activate locales:
  cmd.wait:
    - name: locale-gen
    - watch:
      - file: setup locales