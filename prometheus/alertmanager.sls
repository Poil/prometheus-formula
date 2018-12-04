{% from "prometheus/map.jinja" import prometheus with context %}
alertmanager-{{ prometheus.alertmanager.version }}.linux-amd64:
  archive.extracted:
    - name: {{ prometheus.install_dir }}
    {%- if prometheus.alertmanager.source %}
    - source: {{ prometheus.alertmanager.source }}
    {%- else %}
    - source: https://github.com/prometheus/alertmanager/releases/download/v{{ prometheus.alertmanager.version }}/alertmanager-{{ prometheus.alertmanager.version }}.linux-amd64.tar.gz
    {%- endif %}
    - user: root
    - group: root
    - skip_verify: True
    - if_missing: {{ prometheus.install_dir }}/alertmanager-{{ prometheus.alertmanager.version }}.linux-amd64

{{ prometheus.install_dir }}/alertmanager:
  file.symlink:
    - target: {{ prometheus.install_dir }}/alertmanager-{{ prometheus.alertmanager.version }}.linux-amd64

alertmanager_service_file:
  file.managed:
    - name: /etc/systemd/system/alertmanager.service
    - replace: False
    - user: root
    - group: root
    - mode: '0644'

alertmanager.service:
  service.running:
    - enable: True
    - watch:
      - /etc/systemd/system/alertmanager.service

/etc/systemd/system/alertmanager.service:
  ini.options_present:
    - separator: '='
    - strict: True
    - sections:
        Unit:
          Description: Alert Manager
        Service:
          User: prometheus
          ExecStart: {{ prometheus.install_dir }}/alertmanager/alertmanager --config.file={{ prometheus.install_dir }}/alertmanager/alertmanager.yml
          {%- if prometheus.alertmanager.cluster -%}
            {%- for key, value in prometheus.alertmanager.cluster.items() -%}
              {{ " " }}--cluster.{{ key }}={{ value }}
            {%- endfor -%}
          {% endif %}
        Install:
          WantedBy: multi-user.target

{{ prometheus.install_dir }}/alertmanager/prometheus.yml:
  file.serialize:
    - dataset:
        {{ prometheus.alertmanager.config | yaml() | indent(8) }}
    - formatter: yaml
    - user: root
    - group: root
    - mode: '0644'
