include:
  - hashistack.consul-base
  - hashistack.consul-server-config

consul:
  service.running:
    - enable: True
    - watch:
      - sls: hashistack.consul-base
      - sls: hashistack.consul-server-config
