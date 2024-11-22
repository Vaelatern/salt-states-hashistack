/etc/nomad.d/50-server.hcl:
  file.managed:
    - source: salt://hashistack/nomad-server.hcl
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /etc/nomad.d

/etc/nomad.d/51-server-secrets.hcl:
  file.managed:
    - source: salt://hashistack/nomad-server-secrets.hcl
    - template: jinja
    - mode: 600
    - user: root
    - group: root
    - require:
      - file: /etc/nomad.d
