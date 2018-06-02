{%- from "docker/map.jinja" import docker with context -%}

docker_ppa_repo:
  pkgrepo.managed:
    - name: deb [arch={{ grains['osarch'] }}] http://download.docker.com/linux/ubuntu {{ grains['oscodename'] }} stable
    - file: /etc/apt/sources.list.d/docker.list
    - keyid: 9DC858229FC7DD38854AE2D88D81803C0EBFCD88
    - keyserver: keyserver.ubuntu.com
    - require_in:
      - docker_package_dependencies

docker_package_dependencies:
  pkg.installed:
    - pkgs:
      - {{ docker.package }}
{%- for pkg in docker.package_dependencies %}
      - {{ pkg }}
{%- endfor %}

docker_service:
  service.running:
    - name: {{ docker.service }}
    - enable: True
