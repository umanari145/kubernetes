# kubernetes

## docker の復習

### nginx サンプル

イメージからの立ち上げ。8080 ポートで nginx を起動

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

### python でのサンプル

```
docker run --name mypython -d -it -p 8080:80 python:3.7.5-slim
```

ファイルをコンテナ内に送る

```
docker cp server.py mypython(コンテナ内):/(パス)
```

内部の IP アドレスを調査

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

Dockefile からの起動

```
docker image build ./ -t mypython
```

## web-app-db のアプリ

- web リクエストを受け付けるフロント部分(リバースプロキシで app と連携)
- app RESTAPI を定義
- db REDIS で定義

### ファイル構成

- app
  - Dockerfile app の Dockerfile
  - server.py flask での RESTAPI を定義
- web
  - html 静的ファイル
  - Dockerfile web の Dockerfile
  - nginx.tpl nginx のテンプレート
  - start.sh nginx.tpl から nginx.conf を作成

### kubernetes の語句

https://qiita.com/taiteam/items/87922cbec9f18bfa339e

### クラスター（Cluster）

Kubernetes の基本的な概念で、コンテナ化されたアプリケーションをデプロイ、管理、監視するためのコンピュータリソース（ノード）の集合体です。クラスター内のノードはマスターノードとワーカーノードに分かれ、マスターノードはクラスター全体を管理します。

### ノード（Node）

クラスター内の個々の物理的または仮想的なマシンを指します。ノードはコンテナを実行し、クラスター内の計算リソースを提供します。

### 名前空間（Namespace）

Kubernetes クラスター内でリソースを分離するために使用される論理的な仕切りです。名前空間を使用すると、異なるプロジェクトやチームが同じクラスター内でリソースを独立して使用できます。

### ポッド（Pod）

Kubernetes クラスター内で実行される最小単位のデプロイメントユニットで、1 つ以上のコンテナをまとめて実行します。通常、同じポッド内のコンテナは同じホストで実行され、同じネットワーク名前空間とストレージボリュームを共有します。

### レプリカセット（ReplicaSet）

レプリカセットは、特定の数のポッドのインスタンスを確保し、運用中に失敗した場合にポッドを再起動します。レプリカセットはアプリケーションの冗長性を確保するのに役立ちます。

### デプロイメント（Deployment）

デプロイメントは、アプリケーションのバージョン管理とアップグレードを簡素化するための Kubernetes リソースです。デプロイメントはレプリカセットを管理し、新しいバージョンのアプリケーションをデプロイする際にローリングアップデートを実行します。

### サービス（Service）

サービスは、クラスター内のポッドに対するネットワークアクセスを提供します。クライアントがサービスに対してアクセスすることで、バックエンドのポッドの負荷分散や動的な検出が行われます。

### コンテナ（Container）

コンテナはアプリケーションとその依存関係をカプセル化し、異なる環境で一貫性のある実行を提供するための技術です。Kubernetes はコンテナ化されたアプリケーションをデプロイし、管理します。

### kubernetes コマンド

接続情報の確認

```
kubectl config view
```

ノード情報の返却

```
kubectl get nodes
```

pod の立ち上げ

```
kubectl run nginx
```

pod のチェック

```
kubectl get pods

//結果
NAME      READY   STATUS              RESTARTS   AGE
mynginx   0/1     ContainerCreating   0          38s

//STATUS=RUNNINGになったら正式稼働
```

pod の詳細情報

```
kubectl describe pods nginx
```

pod の中に入る(docker exec -it と同じっぽい)

```
kubectl exec -it nginx sh
```

アクセスできるようにする

```
kubectl expose deployment nginx --port 80 --type LoadBalancer
```

pod の削除

```
kubectl delete pod mynginx
```

kubernetes を起動すると当たり前だが docker も合わせて起動している

### yaml ファイルでの起動

- pod.yml pod の yaml ファイル
- service.yml service の yaml ファイル

pod(service)の起動コマンド(run コマンドをファイルで代替する方法)

```
kubectl apply -f pod.yml(service.yml)
```

pod(service)の削除コマンド

```
kubectl delete -f pod.yml(service.yml)
```

起動 service の確認

```
kubectl get services
//動いているサービスと実際に紐づいてるサービスを確認できる
NAME          TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes    ClusterIP   10.96.0.1       <none>        443/TCP        93m
web-service   NodePort    10.98.120.120   <none>        80:30000/TCP   14s
```

この段階で下記 URL にアクセスして、nginx の画面が見えれば OK
http://localhost:30000/

もちろん docker も起動している

### wordpress+mysql

```
# mysqlのpodとserviceを起動
kubectl apply -f mysql_pod.yml -f mysql_service.yml

# wordpressのpodとserviceを起動
kubectl apply -f mysql_pod.yml -f mysql_service.yml

```

http://localhost/
で wordpress ログイン画面へ遷移
