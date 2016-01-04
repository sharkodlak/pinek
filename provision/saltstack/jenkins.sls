include:
  - repositories.jenkins

setup java for jenkins CI:
  pkg.latest:
    - pkgs:
      - default-jre-headless
      - openjdk-7-jre-headless

setup jenkins CI:
  pkg.latest:
    - pkgs:
      - jenkins
  file.managed:
    - name: /etc/default/jenkins
    - source: salt://filesystem/etc/default/jenkins
  service.running:
    - name: jenkins
    - enable: True