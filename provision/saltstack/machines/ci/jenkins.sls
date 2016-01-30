include:
  - repositories.jenkins

Jenkins CI Java setup:
  pkg.latest:
    - pkgs:
      - default-jre-headless
      - openjdk-7-jdk
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
  file.recurse:
    - name: /var/lib/jenkins/.ssh
    - source: salt://filesystem/var/lib/jenkins/.ssh
    - user: jenkins
    - group: jenkins
    - dir_mode: 700
    - file_mode: 744
    - include_empty: True

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

Jenkins CI reenable MD5 HTTP TLS cypher in Java: # until Jenkins will use stronger cypher on their's plugin site
  file.replace:
    - name: /usr/lib/jvm/java-7-openjdk-amd64/jre/lib/security/java.security
    - pattern: (?<=jdk\.certpath\.disabledAlgorithms=)MD2, MD5, RSA keySize < 1024
    - repl: MD2, RSA keySize < 1024

jenkins:
  module.run:
    - name: service.restart
    - m_name: jenkins
    - onchanges:
      - file: Jenkins CI setup
      - file: Jenkins CI reenable MD5 HTTP TLS cypher in Java
  service.running:
    - name: jenkins
    - enable: True
