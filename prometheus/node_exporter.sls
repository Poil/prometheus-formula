{% from "prometheus/map.jinja" import prometheus with context %}
node_exporter-{{ prometheus.node_exporter.version }}.linux-amd64:
  archive.extracted:
    - name: {{ prometheus.install_dir }}
    {%- if prometheus.node_exporter.source %}
    - source: {{ prometheus.node_exporter.source }}
    {%- else %}
    - source: https://github.com/prometheus/node_exporter/releases/download/v{{ prometheus.node_exporter.version }}/node_exporter-{{ prometheus.node_exporter.version }}.linux-amd64.tar.gz
    {%- endif %}
    - user: root
    - group: root
    - if_missing: {{ prometheus.install_dir }}/node_exporter-{{ prometheus.node_exporter.version }}.linux-amd64

{{ prometheus.install_dir }}/node_exporter:
  file.symlink:
    - target: {{ prometheus.install_dir }}/node_exporter-{{ prometheus.node_exporter.version }}.linux-amd64

node_exporter_service_file:
  file.managed:
    - name: /etc/systemd/system/node_exporter.service
    - replace: False
    - user: root
    - group: root
    - mode: '0644'

node_exporter.service:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/node_exporter.service

/etc/systemd/system/node_exporter.service:
  ini.options_present:
    - separator: '='
    - strict: True
    - sections:
        Unit:
          Description: Node Exporter
        Service:
          User: prometheus
          ExecStart: {{ prometheus.install_dir }}/node_exporter/node_exporter --no-collector.diskstats
        Install:
          WantedBy: multi-user.target

