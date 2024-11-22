Hashistack base development packages:
  pkg.installed:
    - pkgs:
      - nomad
      - consul
      - vault
      - packer
      - vagrant

/etc/nomad.d/01-datacenter.hcl:
  file.managed:
    - contents: |
          datacenter = "dc1"

/etc/nomad.d/01-data-dir.hcl:
  file.managed:
    - contents: |
          data_dir = "/opt/nomad"

/etc/nomad.d/20-cni-plugins.hcl:
  file.managed:
    - contents: |
          client {
            cni_path = "/usr/libexec/cni"
          }

/etc/nomad.d/50-server.hcl:
  file.managed:
    - contents: |
          server {
            enabled = true
            bootstrap_expect = 1
          }
          # We need to advertise to localhost to avoid
          # network problems when nethopping
          bind_addr = "127.0.0.1"
          advertise {
                  http = "127.0.0.1"
                  rpc = "127.0.0.1"
                  serf = "127.0.0.1"
          }

/etc/nomad.d/50-client.hcl:
  file.managed:
    - contents: |
          client {
            enabled = true
          }
          plugin "docker" {
            config {
              volumes {
                enabled = true
              }
          {% if salt['pillar.get']('nomad:docker:privileged') %}
              allow_privileged = true
          {% endif %}
            }
          }

/etc/nomad.d/60-enable-raw-exec.hcl:
  file.managed:
    - contents: |
          plugin "raw_exec" {
            config {
              enabled = true
            }
          }

nomad:
  service.running:
    - enable: True
    - watch:
      - file: /etc/nomad.d/*

/etc/consul.d/01-datacenter.hcl:
  file.managed:
    - contents: |
          datacenter = "dc1"

/etc/consul.d/01-data-dir.hcl:
  file.managed:
    - contents: |
          data_dir = "/opt/consul"

/etc/consul.d/50-server.hcl:
  file.managed:
    - contents: |
          server = true

/etc/consul.d/60-bind.hcl:
  file.managed:
    - contents: |
          bind_addr = "127.0.0.1"

/etc/consul.d/60-cluster-bootstrap.hcl:
  file.managed:
    - contents: |
          bootstrap_expect = 1

/opt/consul:
  file.directory:
    - user: _consul
    - group: _consul

consul:
  service.running:
    - enable: True
    - watch:
      - file: /etc/consul.d/*
