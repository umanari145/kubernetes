# kubernetes


## dockerの復習

イメージからの立ち上げ。8080ポートでnginxを起動
```
docker (container) run --name mynginx -d -p 8080:80 nginx:1.9.15-alpine

# --name コンテナの名称
# -d バックグラウンドで実行(コンソールに結果が出てこない)
# -it コンテン内に入ることが可能になる(nginxなどのサーバー入らないがバックグラウンドでプログラムが動かない場合はこれがないと落ちる)
# -p ポートバインディング (ホストのport):(コンテナのport)
# イメージ名
```

コンテナ内に対して何かコマンドを打ちたい時
```
#任意のコマンド
docker exec mynginx sh -c "echo 'aaaa'"

#コンテナ何に入る時
docker exec -it mynginx /bin/sh or sh
```

リポジトリ探索
```
docker search python
```

pythonでのサンプル
```
docker run --name mypython -d -it -p 8080:80 python:3.7.9-sli
```

ファイルをコンテナ内に送る
```
docker cp server.py mypython(コンテナ内):/(パス)
```
