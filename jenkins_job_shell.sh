#Default compose args
COMPOSE_ARGS=" -f jenkins.yml -p jenkins "

#古いコンテナを削除
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v


# ビルド
sudo docker-compose $COMPOSE_ARGS build --no-cache
sudo docker-compose $COMPOSE_ARGS up -d

# ユニットテスト実行
sudo docker-compose $COMPOSE_ARGS run --no-deps --rm -e ENV=UNIT identidock
EPR=$?


# 結合テスト実行
if [ $EPR -eq 0 ]; then
  IP=$(sudo docker inspect -f{{.NetworkSettings.IPAddress}} jenkins_identidock_1)
  CODE=$(curl -sL -w "%{http_code}" $IP:9090/monster/bla -o /dev/null) || true
  if [ $CODE -ne 200 ]; then
    echo "Site returned " $CODE
    EPR=1
  fi
fi

# dockerイメージを削除
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

return $EPR
