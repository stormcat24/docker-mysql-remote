#!/usr/bin/env bash

apt-get install pv

SOURCES=(`echo $IMPORT_SOURCES | tr -s '|' ' '`)

for SOURCE in ${SOURCES[@]}
do
  SOURCE_TOKENS=(`echo $SOURCE | tr -s ',' ' '`)
  TARGET_HOST=${SOURCE_TOKENS[0]}
  TARGET_PORT=${SOURCE_TOKENS[1]}
  TARGET_USERNAME=${SOURCE_TOKENS[2]}
  TARGET_PASSWORD=${SOURCE_TOKENS[3]}
  TARGET_DATABASE=${SOURCE_TOKENS[4]}

  echo $TARGET_DATABASE
  GET_SIZE="SELECT table_schema AS \`database\`, ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS \`size\` FROM information_schema.TABLES GROUP BY table_schema HAVING \`database\` = '${TARGET_DATABASE}';"

  TARGET_SIZE=$(mysql -s -N -u ${TARGET_USERNAME} -h ${TARGET_HOST} -p${TARGET_PASSWORD} -e "${GET_SIZE}" | awk -F '\t' {'print $2'} )
  echo "target size for ${TARGET_DATABASE} = ${TARGET_SIZE%.*}M"

  DUMP_FILE=/tmp/${TARGET_HOST}_${TARGET_DATABASE}.sql
  mysqldump -h $TARGET_HOST -u $TARGET_USERNAME -p$TARGET_PASSWORD $TARGET_DATABASE | pv -s ${TARGET_SIZE%.*}M > $DUMP_FILE
  if [ $? -ne 0 ]; then
    echo "Failed to dump $TARGET_HOST" 1>&2
    exit 1
  fi

  mysql -u root --password=$MYSQL_ROOT_PASSWORD -e "CREATE DATABASE IF NOT EXISTS $TARGET_DATABASE;"
  if [ $? -ne 0 ]; then
    echo "Failed to create database $TARGET_DATABASE" 1>&2
    exit 1
  fi

  mysql -u root --password=$MYSQL_ROOT_PASSWORD $TARGET_DATABASE < $DUMP_FILE
  if [ $? -ne 0 ]; then
    echo "Failed to import data $TARGET_DATABASE" 1>&2
    exit 1
  fi
done
