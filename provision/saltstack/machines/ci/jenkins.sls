setup java for jenkins CI:
  pkg.latest:
    - pkgs:
      - default-jre-headless
      - openjdk-7-jre-headless

setup jenkins CI:
  pkg.latest:
    - pkgs:
      - jenkins
  user.present:
    - name: jenkins
    - password: {{pillar['jenkins']['user']['hash']}}
  file.managed:
    - name: /etc/default/jenkins
    - source: salt://filesystem/etc/default/jenkins

prepare directory for SSH key:
  file.directory:
    - name: /var/lib/jenkins/.ssh
    - user: jenkins
    - group: jenkins
    - mode: 700
    - makedirs: True

create SSH key:
  file.managed:
    - name: /var/lib/jenkins/.ssh/id_rsa
    - contents_pillar: jenkins:user:id_rsa
    - user: jenkins
    - group: jenkins
    - mode: 700

create SSH public key:
  file.managed:
    - name: /var/lib/jenkins/.ssh/id_rsa.pub
    - contents_pillar: jenkins:user:id_rsa.pub
    - user: jenkins
    - group: jenkins
    - mode: 744

jenkins:
  module.run:
    - name: service.restart
    - m_name: jenkins
  service.running:
    - name: jenkins
    - enable: True
