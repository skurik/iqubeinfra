pgcli:
  pip.installed:
    - require:
      - pkg: python-pip
      - pkg: libpq-dev

python-pip:
  pkg.installed: []

libpq-dev:
  pkg.installed: []