{%- from "docker/map.jinja" import docker with context -%}
{%- set path = salt['pillar.get']('docker:config:path:linux', docker.path.linux) -%}
{%- set containers = salt['pillar.get']('docker:standalone', {}) -%}

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

{% for container, options in containers.items() %}
{{ path }}/{{ container }}:
  file.managed:
    - context:
        name: {{ container }}
        options: {{ options }}
    - name: {{ path }}/{{ container }}
    - source: 'salt://docker/files/container_standalone.jinja'
    - template: jinja
    - dir_mode: 0750
    - file_mode: 0740
    - user: root
    - group: staff
{% endfor %}

docker_service:
  service.running:
    - name: {{ docker.service }}
    - enable: True
