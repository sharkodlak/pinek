include:
  - repositories.jenkins

Jenkins CI Java setup:
  pkg.latest:
    - pkgs:
      - default-jre-headless
      - openjdk-7-jre-headless
    - require:
      - pkgrepo: Jenkins CI repo

Jenkins CI setup:
  pkg.latest:
    - pkgs:
      - jenkins
  file.replace:
    - name: /etc/default/jenkins
    - pattern: (?<=HTTP_PORT=)8080
    - repl: {{pillar['jenkins']['port']}}
    - onchanges:
      - pkg: Jenkins CI setup
  user.present:
    - name: jenkins
    - password: {{pillar['jenkins']['user']['hash']}}

Jenkins CI SSH keys directory:
  file.directory:
    - name: /var/lib/jenkins/.ssh
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: True

Jenkins CI SSH key:
  file.managed:
    - name: /var/lib/jenkins/.ssh/id_rsa
    - contents_pillar: jenkins:key:id_rsa
    - user: jenkins
    - group: jenkins
    - mode: 700
    - onchanges:
      - file: Jenkins CI SSH keys directory

Jenkins CI SSH public key:
  file.managed:
    - name: /var/lib/jenkins/.ssh/id_rsa.pub
    - contents_pillar: jenkins:key:id_rsa.pub
    - user: jenkins
    - group: jenkins
    - mode: 744
    - onchanges:
      - file: Jenkins CI SSH keys directory

jenkins:
  module.run:
    - name: service.restart
    - m_name: jenkins
    - onchanges:
      - file: Jenkins CI setup
  service.running:
    - name: jenkins
    - enable: True
