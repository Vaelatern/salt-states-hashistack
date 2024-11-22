include:
  - hashistack

/opt/nomad:
  file.directory

/etc/nomad.d:
  file.directory:
    - require:
      - sls: hashistack

nomad package:
  pkg.installed:
    - name: nomad
    - require:
      - sls: hashistack

{% if grains['init'] == 'runit' %}

/etc/sv/nomad/check:
  file.managed:
    - mode: 755
    - user: root
    - group: root
    - contents: |
        #!/bin/sh
        exec nomad server members
    - require:
      - pkg: nomad package

{% elif grains['init'] == 'systemd' %}

/etc/systemd/system/nomad.service.d:
  file.directory

/etc/systemd/system/nomad.service.d/wants-consul.conf:
  file.managed:
    - contents: |
       [Unit]
       Wants=consul.service
       After=consul.service

# We don't want to confuse people with the Ubuntu packaging decision
/etc/nomad.d/nomad.hcl:
  file.absent:
    - require:
      - pkg: nomad package

{% endif %}

/etc/nomad.d/01-datacenter.hcl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        datacenter = "{{ salt['pillar.get']('hashicorp_datacenter_name') }}"
    - require:
      - file: /etc/nomad.d

/etc/nomad.d/01-data-dir.hcl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        data_dir = "/opt/nomad"
    - require:
      - file: /etc/nomad.d

/etc/nomad.d/02-tls.hcl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        tls {
          http = false
          rpc = false
          verify_https_client = false
        }
