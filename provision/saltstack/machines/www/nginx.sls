nginx setup:
  pkg.latest:
    - pkgs:
      - nginx
  file.managed:
    - name: /etc/nginx/sites-available/default
    - source: salt://filesystem/etc/nginx/sites-available/default
  module.run:
    - name: service.reload
    - m_name: nginx
    - onchanges:
      - file: nginx setup
  service.running:
    - name: nginx
    - enable: True
