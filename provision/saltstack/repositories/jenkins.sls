Jenkins CI:
  pkgrepo.managed:
    - name: deb http://pkg.jenkins-ci.org/debian binary/
    - humanname: Jenkins CI
    - file: /etc/apt/sources.list.d/jenkins.list
    - key_url: https://jenkins-ci.org/debian/jenkins-ci.org.key
    - refresh_db: true
