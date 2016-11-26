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
      - "local\tall\tiqube_admin\ttrust"
      - "host\tall\tall\t0.0.0.0/0\tmd5"
    - require:
      - postgres_user: iqube_admin      
      - file: iqube_admin_access_remove_default

postgres_listen_on_all_ifaces:
  file.replace:
    - name: "/etc/postgresql/9.6/main/postgresql.conf"
    - pattern: "^\\s*#?\\s*listen_addresses.*=.*"
    - repl: "listen_addresses = '*'"

#postgres_reload_config:
#  cmd.run:
#    - name: "pg96restart.sh"
#    - require:
#      - file: iqube_admin_access
#      - file: postgres_listen_on_all_ifaces
#      - file: pgctl_helper_restart

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

pgctl_helper_reload:
  file.managed:
    - name: "/usr/local/bin/pg96reload.sh"
    - source: "/srv/salt/files/pg96reload.sh"
    - mode: 0550

pgctl_helper_stopfast:
  file.managed:
    - name: "/usr/local/bin/pg96stopfast.sh"
    - source: "/srv/salt/files/pg96stopfast.sh"
    - mode: 0550

pgctl_helper_start:
  file.managed:
    - name: "/usr/local/bin/pg96start.sh"
    - source: "/srv/salt/files/pg96start.sh"
    - mode: 0550

pgctl_helper_restart:
  file.managed:
    - name: "/usr/local/bin/pg96restart.sh"
    - source: "/srv/salt/files/pg96restart.sh"
    - mode: 0550