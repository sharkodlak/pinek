Jenkins CI CLI setup:
  file.managed:
    - name: ~/jenkins-cli.jar
    - source: http://127.0.0.1:{{pillar['jenkins']['port']}}/jnlpJars/jenkins-cli.jar
    - source_hash: md5=3490630c3224fcd9628bdeb7be33711a

#Jenkins CI CLI login:
#  cmd.run:
#    - name: java -jar jenkins-cli.jar -s http://127.0.0.1:{{pillar['jenkins']['port']}}/ login --username {{pillar['jenkins']['user']['username']}} --password '{{pillar['jenkins']['user']['password']}}'
#    - require:
#      - file: Jenkins CI CLI setup

Jenkins CI install plugins:
  cmd.run:
    - name: java -jar jenkins-cli.jar -s http://localhost:{{pillar['jenkins']['port']}} install-plugin checkstyle cloverphp crap4j dry github htmlpublisher jdepend plot pmd violations warnings xunit
    - require:
      - file: Jenkins CI CLI setup

Jenkins CI restart after plugins install:
  cmd.run:
    - name: java -jar jenkins-cli.jar -s http://localhost:{{pillar['jenkins']['port']}} safe-restart
    - onchanges:
      - cmd: Jenkins CI install plugins
