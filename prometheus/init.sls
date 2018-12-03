{% from "prometheus/map.jinja" import prometheus with context %}
include:
  {%- if prometheus.server.enable or prometheus.node_exporter.enable %}
  - prometheus.common
  {% endif %}
  {%- if prometheus.server.enable %}
  - prometheus.server
  {%- endif %}
  {%- if prometheus.node_exporter.enable %}
  - prometheus.node_exporter
  {%- endif %}
  {%- if prometheus.snmp_exporter.enable %}
  - prometheus.snmp_exporter
  {%- endif %}
