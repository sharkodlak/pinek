Jenkins wait for server ready:
  cmd.run:
    - name: COUNTER=0 && until `curl --silent --connect-timeout 1 -I http://127.0.0.1:{{ pillar['jenkins']['port'] }} | grep --quiet '200 OK'` || [ $COUNTER -ge 60 ]; do COUNTER=$(($COUNTER+1)); sleep 1; done

Jenkins CI CLI setup:
  file.managed:
    - name: ~/jenkins-cli.jar
    - source: http://127.0.0.1:{{ pillar['jenkins']['port'] }}/jnlpJars/jenkins-cli.jar
    - source_hash: md5=71316c21e4a2e13a1d7780ec8de7d335
    - require:
      - cmd: Jenkins wait for server ready

#Jenkins CI CLI login:
#  cmd.run:
#    - name: java -jar jenkins-cli.jar -s http://127.0.0.1:{{ pillar['jenkins']['port'] }}/ login --username {{ pillar['jenkins']['user']['username'] }} --password '{{ pillar['jenkins']['user']['password'] }}'
#    - require:
#      - file: Jenkins CI CLI setup

Jenkins CI install plugins:
  cmd.run:
    - name: java -jar jenkins-cli.jar -s http://localhost:{{ pillar['jenkins']['port'] }} install-plugin checkstyle cloverphp crap4j dry github htmlpublisher jdepend plot pmd violations warnings xunit
    - require:
      - file: Jenkins CI CLI setup

Jenkins CI restart after plugins install:
  cmd.run:
    - name: java -jar jenkins-cli.jar -s http://localhost:{{ pillar['jenkins']['port'] }} safe-restart
    - onchanges:
      - cmd: Jenkins CI install plugins
