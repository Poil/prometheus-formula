# Configure Server

```yaml
{%- set nodes = salt.saltutil.runner('mine.get',
  tgt='*',
  fun='grains.item',
  tgt_type='glob') %}

prometheus:
  source: http://repos.local/static/prometheus-2.5.0.linux-amd64.tar.gz
  server:
    enable: True
    config:
      scrape_configs:
        - job_name: 'prometheus'
          static_configs:
            - targets:
              {% for node, fqdn_data in nodes.items() %}
              - {{ fqdn_data['fqdn'] }}:9100
              {% endfor %}
```

# Configure Node Exporter

```yaml
prometheus:
  server:
    enable: False
  node_exporter:
    enable: True
    source: https://repos.local/pulp/static/src/node_exporter-0.17.0-rc.0.linux-amd64.tar.gz

mine_functions:
   grains.item: [fqdn]
```
