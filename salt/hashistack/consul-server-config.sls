/etc/consul.d/50-server.hcl:
  file.managed:
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /etc/consul.d
    - contents: |
        server = true
        bootstrap_expect = 1

{% if salt['pillar.get']('consul_singleton') and grains['init'] == 'systemd'  %}
/etc/systemd/system/consul.service.d:
  file.directory

/etc/systemd/system/consul.service.d/consul-is-singleton.conf:
  file.managed:
    - contents: |
        [Service]
        Type=exec

{% elif grains['init'] == 'systemd' %}

/etc/systemd/system/consul.service.d/consul-is-singleton.conf:
  file.absent

/etc/systemd/system/consul.service.d:
  file.absent

{% endif %}
