include:
  - hashistack

/opt/consul:
  file.directory

consul package:
  pkg.installed:
    - name: consul
    - require:
      - sls: hashistack

/etc/consul.d:
  file.directory:
    - require:
      - sls: hashistack
      - pkg: consul package

{% if grains['init'] == 'runit' %}

/etc/sv/consul/check:
  file.managed:
    - mode: 755
    - user: root
    - group: root
    - contents: |
        #!/bin/sh
        exec consul members
    - require:
      - pkg: consul package

{% elif grains['init'] == 'systemd' %}

# We don't want to confuse people with the Ubuntu packaging decision
/etc/consul.d/consul.hcl:
  file.managed:
    - require:
      - pkg: consul package
    - contents: |
        # Not empty to allow the default systemd service to run

{% endif %}

/etc/consul.d/01-datacenter.hcl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        datacenter = "{{ salt['pillar.get']('hashicorp_datacenter_name') }}"
    - require:
      - file: /etc/consul.d

/etc/consul.d/01-data-dir.hcl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        data_dir = "/opt/consul"
    - require:
      - file: /etc/consul.d

/etc/consul.d/10-web-ui.hcl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        ui = true
    - require:
      - file: /etc/consul.d

/etc/consul.d/10-log-level.hcl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        log_level = "INFO"
    - require:
      - file: /etc/consul.d

/etc/consul.d/10-enable-consul-connect.hcl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        connect = {
          enabled = true
        }
        ports = {
          grpc = 8502
        }
    - require:
      - file: /etc/consul.d

/etc/consul.d/20-bind.hcl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        bind_addr = "{{ salt['pillar.get']('consul_bind_addr') }}"
    - require:
      - file: /etc/consul.d

{% if grains['init'] == 'systemd' %}

/etc/systemd/resolved.conf.d:
  file.directory

/etc/systemd/resolved.conf.d/consul.conf:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents: |
        [Resolve]
        DNS=127.0.0.1
        DNSSEC=false
        Domains=~consul
    - require:
      - file: /etc/systemd/resolved.conf.d

systemd-resolved:
  service.running:
    - enable: true
    - watch:
      - file: /etc/systemd/resolved.conf.d/consul.conf

because we need to mess with the firewall we need iptables-persistent:
  pkg.installed:
    - name: iptables-persistent

tcp for dns on systemd at or under 245:
  iptables.append:
    - table: nat
    - chain: OUTPUT
    - destination: localhost
    - protocol: tcp
    - match: tcp
    - dport: 53
    - jump: REDIRECT
    - to-port: 8600
    - require:
      - pkg: because we need to mess with the firewall we need iptables-persistent

udp for dns on systemd at or under 245:
  iptables.append:
    - table: nat
    - chain: OUTPUT
    - destination: localhost
    - protocol: udp
    - match: udp
    - dport: 53
    - jump: REDIRECT
    - to-port: 8600
    - require:
      - pkg: because we need to mess with the firewall we need iptables-persistent

{% endif %}
