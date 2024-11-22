/etc/hashistack.d:
  file.absent

{% if grains['os_family'] == 'Void' %}

void-repo-nonfree:
  pkg.installed

Sync nonfree:
  pkg.uptodate:
    - refresh: True
    - watch:
      - pkg: void-repo-nonfree


{% elif grains['os_family'] == 'Debian' %}

#######################################
########### The repo ##################
#######################################

/usr/share/keyrings/hashicorp-archive-keyring:
  file.managed:
    - source: https://apt.releases.hashicorp.com/gpg
    - source_hash: cafb01beac341bf2a9ba89793e6dd2468110291adfbb6c62ed11a0cde6c09029

gpg --dearmor /usr/share/keyrings/hashicorp-archive-keyring:
  cmd.run:
    - requires:
      - file: /usr/share/keyrings/hashicorp-archive-keyring
    - creates: /usr/share/keyrings/hashicorp-archive-keyring.gpg

/etc/apt/sources.list.d/hashicorp.list:
  file.managed:
    - contents: "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com {{ grains['lsb_distrib_codename'] }} main"

apt-get update:
  cmd.run:
    - onchanges:
      - file: /etc/apt/sources.list.d/hashicorp.list
      - cmd: gpg --dearmor /usr/share/keyrings/hashicorp-archive-keyring

#######################################
###########> END repo <################
#######################################

{% endif %}
