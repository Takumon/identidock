#!/bin/bash
set -e

if [ "$ENV" = 'DEV' ];then
  echo "開発環境サーバとして起動します。"
  exec python "identidock.py"
else
  echo "本番環境サーバとして起動します。"
  exec uwsgi --http 0.0.0.0:9090 --wsgi-file /app/identidock.py \
             --callable app --stats 0.0.0.0:9191
fi
