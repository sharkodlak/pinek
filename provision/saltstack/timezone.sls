setup timezone:
  file.managed:
    - name: /etc/timezone
    - source: salt://filesystem/etc/timezone
    - user: root
    - group: root
    - mode: 644

activate timezone:
  cmd.wait:
    - name: dpkg-reconfigure --frontend noninteractive tzdata
    - watch:
      - file: setup timezone