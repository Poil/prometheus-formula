{% from "prometheus/map.jinja" import prometheus with context %}
prometheus:
  user.present:
    - fullname: Prometheus
    - shell: /sbin/nologin
    - createhome: False
    - system: True


