include:
  - hashistack.nomad-base
  - hashistack.nomad-client-config
  - hashistack.nomad-server-config

nomad:
  service.running:
    - enable: True
    - watch:
      - sls: hashistack.nomad-base
      - sls: hashistack.nomad-client-config
      - sls: hashistack.nomad-server-config
