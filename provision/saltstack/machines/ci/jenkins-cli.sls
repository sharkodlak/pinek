Jenkins setup CLI:
  file.managed:
    - name: ~/jenkins-cli.jar
    - source: http://127.0.0.1:8081/jnlpJars/jenkins-cli.jar
    - source_hash: md5=3490630c3224fcd9628bdeb7be33711a

Jenkins CLI login:
  cmd.wait:
    - name: java -jar jenkins-cli.jar -s http://127.0.0.1:{{pillar['jenkins']['port']}}/ login --username {{pillar['jenkins']['user']['username']}} --password '{{pillar['jenkins']['user']['password']}}'
    - watch:
      - file: Jenkins setup CLI

Jenkins install plugins:
  cmd.wait:
    - name: java -jar jenkins-cli.jar -s http://localhost:{{pillar['jenkins']['port']}} install-plugin checkstyle cloverphp crap4j dry github htmlpublisher jdepend plot pmd violations warnings xunit
    - watch:
      - cmd: Jenkins CLI login

Jenkins restart after plugins install:
  cmd.wait:
    - name: java -jar jenkins-cli.jar -s http://localhost:{{pillar['jenkins']['port']}} safe-restart
    - watch:
      - cmd: Jenkins install plugins
