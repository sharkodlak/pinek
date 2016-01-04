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