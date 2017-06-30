# Unitテストをどの権限でも実行できるようにしておく
chmod 777 app/*

# 定数定義
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
  if [ $CODE -eq 200 ]; then
    echo "テスト成功 - タグ付けします"
    HASH=$(git rev-parse --short HEAD)
    sudo docker tag -f jenkins_identidock takumon/identidock:$HASH
    sudo docker tag -f jenkins_identidock takumon/indentidock:newest
    echo "プッシュします。"
    sudo docker login $DOCKER_ACOUNT
    sudo docker push takumon/identidock:$HASH
    sudo docker push takumon/indentidock:newest
  else
    echo "テスト失敗　終了します。" $CODE
    EPR=1
  fi
fi

# dockerイメージを削除
sudo docker-compose $COMPOSE_ARGS stop
sudo docker-compose $COMPOSE_ARGS rm --force -v

return $EPR
