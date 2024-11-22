client {
  enabled = true
  cni_path = "/usr/libexec/cni"
}

plugin "raw_exec" {
  config {
    enabled = true
  }
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
