include:
  - hashistack

vault package:
  pkg.installed:
    - name: vault

{% if grains['init'] == 'runit' %}

/etc/sv/vault/conf:
  file.managed:
    - contents: |
        OPTS="server -config=/etc/vault.d"

{% elif grains['init'] == 'systemd' %}

/etc/systemd/system/vault.service.d:
  file.directory

/etc/systemd/system/vault.service.d/change-exec-line.conf:
  file.managed:
    - contents: |
       [Service]
       ExecStart=
       ExecStart=/usr/bin/vault server -config=/etc/vault.d/

{% endif %}

/etc/vault.d:
  file.directory:
    - user: vault
    - group: vault
    - mode: 0755

{% if grains['init'] == 'systemd' %}

/etc/vault.d/vault.hcl:
  file.managed:
    - contents: |
        # This file intentionally left blank

{% endif %}

/etc/vault.d/25-storage.hcl:
  file.managed:
    - user: vault
    - group: vault
    - mode: 0640
    - contents: |
        storage "consul" {
          address = "127.0.0.1:8500"
          path    = "vault"
        
          {% raw %}
          #token = "{{lookup('file', 'secret/vault_consul_token')}}"
          {% endraw %}
        }

/etc/vault.d/30-listeners.hcl:
  file.managed:
    - user: vault
    - group: vault
    - mode: 0640
    - contents: |
        listener "tcp" {
          address = "0.0.0.0:8200"
          tls_disable = true
        
          telemetry {
            unauthenticated_metrics_access = true
          }
        }

vault:
  service.running:
    - enable: true
    - watch:
      - file: /etc/vault.d/*
      - pkg: vault package
