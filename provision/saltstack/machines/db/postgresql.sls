PostgreSQL setup:
  pkg.latest:
    - pkgs:
      - postgresql

PostgreSQL listen on all interfaces:
  file.patch:
    - name: /etc/postgresql/9.4/main/postgresql.conf
    - source: salt://filesystem/etc/postgresql/9.4/main/postgresql.conf.patch
    - hash: md5=24df3376ac5b7fdc09bfc1e24d900ad3

PostgreSQL allow temporal access without password:
  file.patch:
    - name: /etc/postgresql/9.4/main/pg_hba.conf
    - source: salt://filesystem/etc/postgresql/9.4/main/pg_hba.conf.trust.patch
    - hash: md5=06511bf7fb53e8a2f1978db8a987c190

PostgreSQL reload to allow trusted access:
  module.run:
    - name: service.reload
    - m_name: postgresql
    - onchanges:
      - file: PostgreSQL allow temporal access without password

PostgreSQL add common users:
  postgres_group.present:
    - name: commonUsers
    - createdb: False
    - createuser: False
    - encrypted: True
    - replication: False
    - onchanges:
      - module: PostgreSQL reload to allow trusted access
  postgres_user.present:
    - name: {{pillar['db']['commonUser']['username']}}
    - password: {{pillar['db']['commonUser']['password']}}
    - groups: commonUsers
    - onchanges:
      - postgres_group: PostgreSQL add common users

PostgreSQL add power users:
  postgres_group.present:
    - name: powerUsers
    - createdb: True
    - createuser: True
    - encrypted: True
    - replication: True
    - groups: {{pillar['db']['commonUser']['username']}}
    - onchanges:
      - postgres_user: PostgreSQL add common user
  postgres_user.present:
    - name: {{pillar['db']['powerUser']['username']}}
    - password: {{pillar['db']['powerUser']['password']}}
    - groups: powerUsers
    - onchanges:
      - postgres_group: PostgreSQL add power users

PostgreSQL allow only password access:
  file.patch:
    - name: /etc/postgresql/9.4/main/pg_hba.conf
    - source: salt://filesystem/etc/postgresql/9.4/main/pg_hba.conf.patch
    - hash: md5=395786aad5e25b6b430f580c3c0ee773
    - onchanges:
      - postgres_user: PostgreSQL add power user

postgresql:
  module.run:
    - name: service.reload
    - m_name: postgresql
    - onchanges:
      - file: PostgreSQL allow only password access
  service.running:
    - enable: True
