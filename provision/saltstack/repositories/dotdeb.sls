dotdeb:
  pkgrepo.managed:
    - humanname: Dotdeb
    - name: deb http://packages.dotdeb.org jessie all
    - file: /etc/apt/sources.list.d/dotbeb.list
    - keyid: 89DF5277
    - keyserver: keys.gnupg.net
    - refresh_db: true
