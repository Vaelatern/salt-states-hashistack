/etc/runit/core-services/20-make-shared.sh:
  file.managed:
    - contents: |
        _nomad_dir = /opt/nomad/
        while ! mountpoint "$_nomad_dir" >/dev/null; do
          _nomad_dir="$(dirname "$_nomad_dir")"
        done
        [ -n "$_nomad_dir" ] && mount --make-shared "$_nomad_dir"
    - mode: 644
    - user: root
    - group: root

cni:
  pkg.installed

cni-plugins:
  pkg.installed

/etc/nomad.d/50-client.hcl:
  file.managed:
    - source: salt://hashistack/nomad-client.hcl
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /etc/nomad.d

{% for volume in salt['pillar.get']('host_volumes') %}
{{ volume.path }}:
  file.directory

/etc/nomad.d/50-client-volume-{{ volume.name }}.hcl:
  file.managed:
    - contents: |
        client {
          host_volume {{ volume.name }} {
            path = "{{ volume.path }}"
            read_only = {{ volume.read_only | lower }}
          }
        }
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /etc/nomad.d
{% endfor %}
