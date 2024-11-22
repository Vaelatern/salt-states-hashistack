include:
  - hashistack.consul-base
  - hashistack.consul-client-config

consul:
  service.running:
    - enable: True
    - watch:
      - sls: hashistack.consul-base
      - sls: hashistack.consul-client-config
