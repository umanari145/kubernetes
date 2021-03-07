# kubernetes


## dockerの復習

### nginxサンプル

イメージからの立ち上げ。8080ポートでnginxを起動
```
docker (container) run --name mynginx  --rm -d -p 8080:80 nginx:1.9.15-alpine

# --name コンテナの名称
# --rm 終了時に自動的に削除
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

### pythonでのサンプル
```
docker run --name mypython -d -it -p 8080:80 python:3.7.5-slim
```

ファイルをコンテナ内に送る
```
docker cp server.py mypython(コンテナ内):/(パス)
```

内部のIPアドレスを調査
```
docker exec mynginx hostname -i
```

### ネットワークに関して
```
docker network ls
NETWORK ID          NAME                      DRIVER              SCOPE
88ce01ffbbad        bridge                    bridge              local
#NAME→bridgeはdefaultのNAT

docker container port 4f62ce0359ea (コンテナID)
#ポートフォーワードが下記のように現れる
80/tcp -> 0.0.0.0:8080
```

### docker build

Dockefileからの起動
```
docker image build ./ -t mypython
```

## web-app-dbのアプリ
- web リクエストを受け付けるフロント部分(リバースプロキシでappと連携)
- app RESTAPIを定義
- db REDISで定義

### ファイル構成
- app 
    - Dockerfile appのDockerfile
    - server.py flaskでのRESTAPIを定義
- web
    - html 静的ファイル
    - Dockerfile webのDockerfile
    - nginx.tpl nginxのテンプレート
    - start.sh nginx.tplからnginx.confを作成


### kubernetesコマンド

接続情報の確認
```
kubectl config view
```

ノード情報の返却
```
kubectl get nodes
```

podの立ち上げ
```
kubectl run nginx
```

podのチェック
```
kubectl get pods

//結果
NAME      READY   STATUS              RESTARTS   AGE
mynginx   0/1     ContainerCreating   0          38s

//STATUS=RUNNINGになったら正式稼働
```

podの詳細情報
```
kubectl describe pods nginx
```

podの中に入る(docker exec -itと同じっぽい)
```
kubectl exec -it nginx sh
```
アクセスできるようにする
```
kubectl expose deployment nginx --port 80 --type LoadBalancer
```

podの削除
```
kubectl delete pod mynginx
```

kubernetesを起動すると当たり前だがdockerも合わせて起動している