include:
  - hashistack.consul-client

consul-template:
  pkg.installed

/var/www/html/consulServiceList.html.ctmpl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - source: salt://hashistack/consul-reverse-proxy/service-list.html

/etc/apache2/sites-available/reverse-proxy.conf.ctmpl:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - source: salt://hashistack/consul-reverse-proxy/apache-site.conf

/etc/systemd/system/consul-template-apache2.service:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - source: salt://hashistack/consul-reverse-proxy/consul-template.service

consul-template-apache2:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/consul-template-apache2.service
      - file: /etc/apache2/sites-available/reverse-proxy.conf.ctmpl

/etc/apache2/sites-enabled/reverse-proxy.conf:
  file.symlink:
    - target: /etc/apache2/sites-available/reverse-proxy.conf

/etc/apache2/sites-enabled/000-default.conf:
  file.absent
