setup-db:
  pkg.installed:
    - pkgs:
      - postgresql

allow postgresql to listen on all interfaces:
  file.patch:
    - name: /etc/postgresql/9.4/main/postgresql.conf
    - source: salt://filesystem/etc/postgresql/9.4/main/postgresql.conf.patch
    - hash: md5=24df3376ac5b7fdc09bfc1e24d900ad3

allow postgresql access without password:
  file.patch:
    - name: /etc/postgresql/9.4/main/pg_hba.conf
    - source: salt://filesystem/etc/postgresql/9.4/main/pg_hba.conf.trust.patch
    - hash: md5=06511bf7fb53e8a2f1978db8a987c190

reload postgresql to allow trusted access:
  module.run:
    - name: service.reload
    - m_name: postgresql

add group for power users:
  postgres_group.present:
    - name: powerUsers
    - createdb: True
    - createuser: True
    - encrypted: True
    - replication: True

add group for common users:
  postgres_group.present:
    - name: commonUsers
    - createdb: False
    - createuser: False
    - encrypted: True
    - replication: False

add power user:
  postgres_user.present:
    - name: {{pillar['db']['powerUser']['username']}}
    - password: {{pillar['db']['powerUser']['password']}}
    - groups: powerUsers

add common user:
  postgres_user.present:
    - name: {{pillar['db']['commonUser']['username']}}
    - password: {{pillar['db']['commonUser']['password']}}
    - groups: commonUsers

allow postgresql access only with password:
  file.patch:
    - name: /etc/postgresql/9.4/main/pg_hba.conf
    - source: salt://filesystem/etc/postgresql/9.4/main/pg_hba.conf.patch
    - hash: md5=395786aad5e25b6b430f580c3c0ee773

postgresql:
  module.run:
    - name: service.reload
    - m_name: postgresql
  service.running:
    - enable: True
