{%- set vmail_id = salt['pillar.get']('dovecot_vmail_id', '999') %}
{%- set vmail_dir = salt['pillar.get']('dovecot_vmail_dir', '/home/vmail') %}
dovecot:
  group.present:
    - name: vmail
    - gid: {{ vmail_id }}
  user.present:
    - name: vmail
    - uid: {{ vmail_id }}
    - gid: {{ vmail_id }}
    - home: {{ vmail_dir }}
    - require:
      - group: dovecot
  file.directory:
    - name: {{ vmail_dir }}
    - user: vmail
    - group: vmail
    - mode: 770
    - require:
      - user: dovecot
  pkg.installed:
    - pkgs:
      - dovecot
      - pigeonhole
  service.running:
    - name: dovecot.service
    - enable: True
    - require:
      - sls: postfix

dovecot_conf:
  file.managed:
    - name: /etc/dovecot/dovecot.conf
    - source: salt://dovecot/files/dovecot.conf
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - file: dovecot_sql_conf
    - watch_in:
      - service: dovecot

dovecot_sql_conf:
  file.managed:
    - name: /etc/dovecot/dovecot-sql.conf.ext
    - source: salt://dovecot/files/dovecot-sql.conf
    - user: root
    - group: root
    - mode: 600
    - template: jinja
    - watch_in:
      - service: dovecot
