setup shell aliases:
  file.managed:
    - name: /home/{{pillar['home']['user']}}/.bash_aliases
    - source: salt://filesystem/home/vagrant/.bash_aliases
    - user: {{pillar['home']['user']}}
    - group: {{pillar['home']['group']}}
    - mode: 664

allow collors in shell:
  file.patch:
    - name: /home/{{pillar['home']['user']}}/.bashrc
    - source: salt://filesystem/home/vagrant/.bashrc.patch
    - hash: md5=711ae167b8ef8214087a4a80de33b62c