server {
  encrypt = "{{ salt['pillar.get']('nomad_secrets:encrypt') }}"
}

{% if salt['pillar.get']('nomad_secrets:vault_token') %}
vault {
  enabled = true
#  create_from_role = "nomad-cluster"
#  address = "http://active.vault.service.consul:8200"
  address = "http://localhost:8200"
  token = "{{ salt['pillar.get']('nomad_secrets:vault_token') }}"
}
{% endif %}
