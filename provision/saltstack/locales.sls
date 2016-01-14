locales setup:
  file.managed:
    - name: /etc/locale.gen
    - source: salt://filesystem/etc/locale.gen
    - user: root
    - group: root
    - mode: 644

locales activate:
  cmd.wait:
    - name: locale-gen
    - onchanges:
      - file: locales setup