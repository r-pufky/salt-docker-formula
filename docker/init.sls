{%- from "docker/map.jinja" import docker with context -%}
{%- set path = salt['pillar.get']('docker:config:path:linux', docker.path.linux) -%}

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

copy_docker_scripts:
  file.recurse:
    - name: {{ path }}
    - source: 'salt://docker/files'
    - template: jinja
    - dir_mode: 0750
    - file_mode: 0740
    - user: root
    - group: staff

docker_service:
  service.running:
    - name: {{ docker.service }}
    - enable: True
