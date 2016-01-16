{% for user, data in pillar.get('users', {}).items() %}
{% if prompt is defined %}
  {% set prompt = data['prompt'] %}
{% else %}
  {% set prompt = {} %}
{% endif %}
shell force colors for user {{ user }}:
  file.replace:
    - name: {{ data['home']|default("/home/" + user) }}/.bashrc
    - pattern: '#force_color_prompt=yes'
    - repl: force_color_prompt=yes

shell colored prompt for user {{ user }}:
  file.replace:
    - name: {{ data['home']|default("/home/" + user) }}/.bashrc
    - pattern: >-
        PS1=('\$\{debian_chroot:\+\(\$debian_chroot\)\}\\\[\\033\[01;32m\\\]\\u@\\h\\\[\\033\[00m\\\]:\\\[\\033\[01;34m\\\]\\w\\\[\\033\[00m\\\]\\\$ '|"\\\$\? .*?\\u.*?@.+ ")
    - repl: |-
        PS1="\$? {{ prompt['userColor']|default('') }}\u\[\e[0m\]@\[${HOST_COLOR:-\e[01;31m}\]\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]{{ prompt['sign']|default('\$') }} "
    - append_if_not_found: True

shell setup host color for user {{ user }}:
  file.replace:
    - name: {{ data['home']|default("/home/" + user) }}/.bashrc
    - pattern: ^HOST_COLOR=.*$
    - repl: HOST_COLOR='{{ grains['color'] }}'
    - append_if_not_found: True

shell include aliases for user {{ user }}:
  file.replace:
    - name: {{ data['home']|default("/home/" + user) }}/.bashrc
    - pattern: |
        if \[ -f ~/\.bash_aliases \]; then
            \. ~/\.bash_aliases
        fi
    - repl: |
        if [ -f ~/.bash_aliases ]; then
            . ~/.bash_aliases
        fi
    - append_if_not_found: True

shell aliases for user {{ user }}:
  file.managed:
    - name: {{ data['home']|default("/home/" + user) }}/.bash_aliases
    - source: salt://filesystem/home/vagrant/.bash_aliases
    - user: {{ user }}
    - group: {{ data['group']|default(user) }}
    - mode: 664
{% endfor %}