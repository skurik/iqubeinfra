postgresql:
  pkg.installed:
    - name: postgresql-9.6
    - require:
      - cmd: update_apt_sources

iqube_admin:
  postgres_user.present:
    - password: "iqube25"
    - login: True
    - encrypted: True
    - require:
      - pkg: postgresql
  file.managed:
    - name: "/etc/postgresql/9.6/main/test.cfg"
    - contents: "test"

iqube_admin_access_remove_default:
  file.replace:
    - name: "/etc/postgresql/9.6/main/pg_hba.conf"
    - pattern: "local\\s+all\\s+all\\s+peer\\s*"
    - repl: ""

iqube_admin_access:  
  file.append:
    - name: "/etc/postgresql/9.6/main/pg_hba.conf"
    - text:      
      - "local all iqube_admin trust"      
    - require:
      - postgres_user: iqube_admin      
      - file: iqube_admin_access_remove_default

iqube:  
  postgres_database.present:
    - require:      
      - pkg: postgresql
      - postgres_user: iqube_admin
    - owner: iqube_admin

update_apt_sources:
  cmd.run:
    - name: "wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -; sudo apt-get update;"
    - require:
      - file: pgdg.list

pgdg.list:
  file.managed:
    - name: /etc/apt/sources.list.d/pgdg.list
    - contents: deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main

pgctl_helpers:
  file.managed:
    - name: "/usr/local/bin/pg96reload.sh"
    - source: "/srv/salt/files/pg96reload.sh"
    - mode: 0550