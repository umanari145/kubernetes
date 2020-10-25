# kubernetes


## dockerの復習

イメージからの立ち上げ。8080ポートでnginxを起動
```

docker (container) run --name mynginx -d -p 8080:80 nginx:1.9.15-alpine

# --name コンテナの名称
# -d バックグラウンド
# -it バックグラウンド コンテン内に入ることが可能になる
# -p ポートバインディング (ホストのport):(コンテナのport)
# イメージ名
```

コンテナ内に対して何かコマンドを打ちたい時
```
#任意のコマンド
docker exec mynginx date

#コンテナ何に入る時
docker exec -it mynginx /bin/sh
```

