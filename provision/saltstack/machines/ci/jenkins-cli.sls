Jenkins wait for server ready:
  cmd.run:
    - name: COUNTER=0 && until `curl --silent --connect-timeout 1 -I http://127.0.0.1:{{ pillar['jenkins']['port'] }} | grep --quiet '200 OK'` || [ $COUNTER -ge 60 ]; do COUNTER=$(($COUNTER+1)); sleep 1; done

Jenkins CI CLI setup:
  cmd.run:
    - name: curl -L http://127.0.0.1:{{ pillar['jenkins']['port'] }}/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar
    - require:
      - cmd: Jenkins wait for server ready
  file.recurse:
    - name: /var/lib/jenkins
    - source: salt://filesystem/var/lib/jenkins
    - user: jenkins
    - group: jenkins
    - dir_mode: 755
    - file_mode: 644

#Jenkins CI CLI login:
#  cmd.run:
#    - name: java -jar jenkins-cli.jar -s http://127.0.0.1:{{ pillar['jenkins']['port'] }}/ login --username {{ pillar['jenkins']['user']['username'] }} --password '{{ pillar['jenkins']['user']['password'] }}'
#    - require:
#      - cmd: Jenkins CI CLI setup

Jenkins CI install plugins:
  cmd.run:
    - name: java -jar jenkins-cli.jar -s http://localhost:{{ pillar['jenkins']['port'] }} install-plugin checkstyle cloverphp crap4j dry github htmlpublisher jdepend plot pmd violations warnings xunit
    - require:
      - cmd: Jenkins CI CLI setup
      - pkg: Git setup

Jenkins CI restart after plugins install:
  cmd.run:
    - name: java -jar jenkins-cli.jar -s http://localhost:{{ pillar['jenkins']['port'] }} safe-restart
    - onchanges:
      - file: Jenkins CI CLI setup
      - cmd: Jenkins CI install plugins
