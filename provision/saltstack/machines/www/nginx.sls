setup nginx:
  pkg.latest:
    - pkgs:
      - nginx

/etc/nginx/sites-available/default:
  file.managed:
    - source: salt://filesystem/etc/nginx/sites-available/default
nginx:
  module.run:
    - name: service.reload
    - m_name: nginx
  service.running:
    - enable: True
