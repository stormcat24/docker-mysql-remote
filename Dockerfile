FROM mysql:5.6.30
MAINTAINER stormcat24 <stormcat24@stormcat.io>

ADD import-data.sh /docker-entrypoint-initdb.d/
