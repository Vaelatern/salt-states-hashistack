{% set server_addresses = salt['pillar.get']('consul_servers')  %}

/etc/consul.d/50-client.hcl:
  file.managed:
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: /etc/consul.d
    - contents: |
        server = false # Consul does stupid things if you run a client on the same box as a server
        # it's also not necessary. Don't do it. The server can act as a client just fine.
        start_join = [{% for ip in server_addresses %}"{{ ip }}"{% endfor %}]
        leave_on_terminate = true
