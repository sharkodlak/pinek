setup jenkins CLI:
  file.managed:
    - name: ~/jenkins-cli.jar
    - source: http://127.0.0.1:8081/jnlpJars/jenkins-cli.jar
    - source_hash: md5=3490630c3224fcd9628bdeb7be33711a
