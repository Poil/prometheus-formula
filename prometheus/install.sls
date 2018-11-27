{% from "prometheus/map.jinja" import prometheus with context %}
prometheus-{{ prometheus.version }}.linux-amd64:
  archive.extracted:
    - name: /opt
    {%- if prometheus.source %}
    - source: {{ prometheus.source }}
    {%- else %}
    - source: https://github.com/prometheus/prometheus/releases/download/v{{ prometheus.version }}/prometheus-{{ prometheus.version }}.linux-amd64.tar.gz
    {%- endif %}
    - user: root
    - group: root
    - if_missing: /opt/prometheus-{{ prometheus.version }}.linux-amd64

prometheus:
  user.present:
    - fullname: Prometheus
    - shell: /sbin/nologin
    - createhome: False
    - system: True
