#!/bin/bash

su postgres -c "/usr/lib/postgresql/9.6/bin/pg_ctl -D /var/lib/postgresql/9.6/main -o '-c config_file=/etc/postgresql/9.6/main/postgresql.conf' start"