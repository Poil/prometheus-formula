{% from "prometheus/map.jinja" import prometheus with context %}
prometheus-{{ prometheus.server.version }}.linux-amd64:
  archive.extracted:
    - name: {{ prometheus.install_dir }}
    {%- if prometheus.server.source %}
    - source: {{ prometheus.server.source }}
    {%- else %}
    - source: https://github.com/prometheus/prometheus/releases/download/v{{ prometheus.server.version }}/prometheus-{{ prometheus.server.version }}.linux-amd64.tar.gz
    {%- endif %}
    - user: root
    - group: root
    - skip_verify: True
    - if_missing: {{ prometheus.install_dir }}/prometheus-{{ prometheus.server.version }}.linux-amd64

{{ prometheus.install_dir }}/prometheus:
  file.symlink:
    - target: {{ prometheus.install_dir }}/prometheus-{{ prometheus.server.version }}.linux-amd64

prometheus_service_file:
  file.managed:
    - name: /etc/systemd/system/prometheus.service
    - replace: False
    - user: root
    - group: root
    - mode: '0644'

/etc/systemd/system/prometheus.service:
  ini.options_present:
    - separator: '='
    - strict: True
    - sections:
        Unit:
          Description: Prometheus Server
          Documentation: https://prometheus.io/docs/introduction/overview/
          After: network-online.target
        Service:
          User: root
          Restart: on-failure
          ExecStart: {{ prometheus.install_dir }}/prometheus/prometheus --config.file={{ prometheus.install_dir }}/prometheus/prometheus.yml --storage.tsdb.retention.time={{ prometheus.server.option.retention_time }}{% if prometheus.server.external_url %} --web.external-url={{ prometheus.server.external_url }}{% endif %}
        Install:
          WantedBy: multi-user.target

prometheus.service:
  service.running:
    - enable: True
    - watch:
      - {{ prometheus.install_dir }}/prometheus/prometheus.yml
      - /etc/systemd/system/prometheus.service
      {% if prometheus.server.rules %}
        {% for file, config in prometheus.server.rules.items() %}
      - {{ prometheus.install_dir }}/prometheus/rules/{{ file }}.yml
        {% endfor %}
      {% endif %}

{{ prometheus.install_dir }}/prometheus/prometheus.yml:
  file.serialize:
    - dataset:
        {{ prometheus.server.config | yaml() | indent(8) }}
    - formatter: yaml
    - user: root
    - group: root
    - mode: '0644'

{{ prometheus.install_dir }}/prometheus/rules:
  file.directory:
    - user: root
    - group: root
    - mode: '0755'

{% if prometheus.server.rules %}
  {% for file, config in prometheus.server.rules.items() %}
{{ prometheus.install_dir }}/prometheus/rules/{{ file }}.yml:
  file.serialize:
    - dataset:
        {{ config | yaml() | indent(8) }}
    - formatter: yaml
    - user: root
    - group: root
    - mode: '0644'
    - require:
      - {{ prometheus.install_dir }}/prometheus/rules
  {% endfor %}
{% endif %}
