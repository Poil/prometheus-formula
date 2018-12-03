{% from "prometheus/map.jinja" import prometheus with context %}
snmp_exporter-{{ prometheus.snmp_exporter.version }}.linux-amd64:
  archive.extracted:
    - name: {{ prometheus.install_dir }}
    {%- if prometheus.snmp_exporter.source %}
    - source: {{ prometheus.snmp_exporter.source }}
    {%- else %}
    - source: https://github.com/prometheus/snmp_exporter/releases/download/v{{ prometheus.snmp_exporter.version }}/snmp_exporter-{{ prometheus.snmp_exporter.version }}.linux-amd64.tar.gz
    {%- endif %}
    - user: root
    - group: root
    - skip_verify: True
    - if_missing: {{ prometheus.install_dir }}/snmp_exporter-{{ prometheus.snmp_exporter.version }}.linux-amd64

{{ prometheus.install_dir }}/snmp_exporter:
  file.symlink:
    - target: {{ prometheus.install_dir }}/snmp_exporter-{{ prometheus.snmp_exporter.version }}.linux-amd64

snmp_exporter_service_file:
  file.managed:
    - name: /etc/systemd/system/snmp_exporter.service
    - replace: False
    - user: root
    - group: root
    - mode: '0644'

snmp_exporter.service:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/snmp_exporter.service

/etc/systemd/system/snmp_exporter.service:
  ini.options_present:
    - separator: '='
    - strict: True
    - sections:
        Unit:
          Description: Node Exporter
        Service:
          User: prometheus
          ExecStart: {{ prometheus.install_dir }}/snmp_exporter/snmp_exporter
        Install:
          WantedBy: multi-user.target

