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

#### クラスター（Cluster）

Kubernetes の基本的な概念で、コンテナ化されたアプリケーションをデプロイ、管理、監視するためのコンピュータリソース（ノード）の集合体です。クラスター内のノードはマスターノードとワーカーノードに分かれ、マスターノードはクラスター全体を管理します。

#### ノード（Node）

クラスター内の個々の物理的または仮想的なマシンを指します。ノードはコンテナを実行し、クラスター内の計算リソースを提供します。

#### 名前空間（Namespace）

Kubernetes クラスター内でリソースを分離するために使用される論理的な仕切りです。名前空間を使用すると、異なるプロジェクトやチームが同じクラスター内でリソースを独立して使用できます。

#### ポッド（Pod）

Kubernetes クラスター内で実行される最小単位のデプロイメントユニットで、1 つ以上のコンテナをまとめて実行します。通常、同じポッド内のコンテナは同じホストで実行され、同じネットワーク名前空間とストレージボリュームを共有します。

#### レプリカセット（ReplicaSet）

レプリカセットは、特定の数のポッドのインスタンスを確保し、運用中に失敗した場合にポッドを再起動します。レプリカセットはアプリケーションの冗長性を確保するのに役立ちます。

#### デプロイメント（Deployment）

デプロイメントは、アプリケーションのバージョン管理とアップグレードを簡素化するための Kubernetes リソースです。デプロイメントはレプリカセットを管理し、新しいバージョンのアプリケーションをデプロイする際にローリングアップデートを実行します。

#### サービス（Service）

サービスは、クラスター内のポッドに対するネットワークアクセスを提供します。クライアントがサービスに対してアクセスすることで、バックエンドのポッドの負荷分散や動的な検出が行われます。

#### コンテナ（Container）

コンテナはアプリケーションとその依存関係をカプセル化し、異なる環境で一貫性のある実行を提供するための技術です。Kubernetes はコンテナ化されたアプリケーションをデプロイし、管理します。

#### Job

Job は、Kubernetes クラスター内で一度だけ実行されるタスクを表すリソースです。通常、ジョブはバッチ処理やデータの一時的な処理、バックアップ、データのクリーンアップなどの一回限りのタスクを実行するのに使用されます。ジョブは成功または失敗のステータスを持ち、必要に応じて再試行することもできます。

#### CronJob

CronJob は、Cron ジョブのスケジュールに基づいて定期的に実行されるタスクを管理するための Kubernetes リソースです。Cron ジョブは特定のスケジュールに従って実行され、一度実行するだけでなく、定期的な実行を設定できます。例えば、毎日午前 3 時にデータベースのバックアップを実行するなどが考えられます。

これらのリソースは、Kubernetes クラスター内でアプリケーションやタスクの実行を自動化し、管理するのに役立ちます。 Job は一回限りのタスク、 CronJob は定期的なスケジュールに基づいたタスクに使用され、Kubernetes の柔軟なスケジューリング機能を活用します。

### kubernetes の使用法

https://qiita.com/nyanchu/items/ecb16ad3ad1f491b5131

### kubernetes コマンド

コンテキストの確認

```
kubectl config get-contexts
```

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
kubectl run mynginx --hostport=8080 --port=80 --image=nginx

// pod/mynginx created とでれば成功
```

pod のチェック

```
kubectl get pods

//結果
NAME      READY   STATUS              RESTARTS   AGE
mynginx   0/1     ContainerCreating   0          38s

//STATUS=RUNNINGになったら正式稼働

// STATUS
// Running： 稼働中
// Pending： Pod起動待ち
// ImageNotReady: dockerイメージ取得中
// PullImageError： dockerイメージ取得失敗
// CreatingContainer: Pod(コンテナ)起動中
// Error: エラー
```

pod の詳細情報

```
kubectl describe pods nginx
```

pod の中に入る(docker exec -it と同じっぽい)

```
kubectl exec -it nginx sh
```

pod の削除

```
kubectl delete pod mynginx
```

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
NAME          TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes    ClusterIP      10.96.0.1       <none>        443/TCP        4h
web-service   LoadBalancer   10.109.29.221   <pending>     80:32460/TCP   70s
```

minikube なのでトンネリングを使う

```
minikube service web-service --url
http://127.0.0.1:56668
❗ Docker ドライバーを darwin 上で使用しているため、実行するにはターミナルを開く必要があります。
```

この場合、
http://127.0.0.1:56668
にアクセスすれば OK

### wordpress+mysql

```
# mysqlのpodとserviceを起動
kubectl apply -f mysql_pod.yml -f mysql_service.yml

# wordpressのpodとserviceを起動
kubectl apply -f wordpress_pod.yml -f wordpress_service.yml

```

`minikube service wordpress-service --url`
トンネリングされた url で wordpress ログイン画面へ遷移

デバッグ

```
kubectl describe pods
以下のようなログがはかれる(エラー時)
・・・
Events:
  Type     Reason     Age                  From               Message
  ----     ------     ----                 ----               -------
  Normal   Scheduled  18m                  default-scheduler  Successfully assigned default/wordpress-pod to docker-desktop
  Normal   Pulling    5m52s (x4 over 17m)  kubelet            Pulling image "wordpress:5.2.3-php7.3-apache"
  Warning  Failed     2m36s (x4 over 14m)  kubelet            Failed to pull image "wordpress:5.2.3-php7.3-apache": rpc error: code = Unknown desc = context deadline exceeded
  Warning  Failed     2m36s (x4 over 14m)  kubelet            Error: ErrImagePull
  Normal   BackOff    106s (x8 over 14m)   kubelet            Back-off pulling image "wordpress:5.2.3-php7.3-apache"
  Warning  Failed     106s (x8 over 14m)   kubelet            Error: ImagePullBackOff
matsumotonorio@matsumotogaseinoMacBook-Pro kubernetes % kubectl logs  --all-containers

dockerのimageは元々pullしておかないとダメっぽいのでdocker image pull xxxxx をする必要がある

```

ログ

```
kubectl logs  -f wordpress-pod --tail=10
WordPress not found in /var/www/html - copying now...
Complete! WordPress has been successfully copied to /var/www/html
No 'wp-config.php' found in /var/www/html, but 'WORDPRESS_...' variables supplied; copying 'wp-config-docker.php' (WORDPRESS_DB_HOST WORDPRESS_DB_NAME WORDPRESS_DB_PASSWORD WORDPRESS_DB_USER WORDPRESS_SERVICE_PORT WORDPRESS_SERVICE_PORT_80_TCP WORDPRESS_SERVICE_PORT_80_TCP_ADDR WORDPRESS_SERVICE_PORT_80_TCP_PORT WORDPRESS_SERVICE_PORT_80_TCP_PROTO WORDPRESS_SERVICE_SERVICE_HOST WORDPRESS_SERVICE_SERVICE_PORT)
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.1.0.31. Set the 'ServerName' directive globally to suppress this message
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.1.0.31. Set the 'ServerName' directive globally to suppress this message
[Tue Jan 23 12:48:18.322868 2024] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.56 (Debian) PHP/8.0.28 configured -- resuming normal operations
[Tue Jan 23 12:48:18.322935 2024] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'
```

```
kubectl get events
LAST SEEN   TYPE      REASON          OBJECT        MESSAGE
13m         Normal    Scheduled       pod/web-pod   Successfully assigned default/web-pod to docker-desktop
13m         Normal    Pulled          pod/web-pod   Container image "nginx:1.17.6-alpine" already present on machine
13m         Normal    Created         pod/web-pod   Created container nginx
13m         Normal    Started         pod/web-pod   Started container nginx
4m59s       Normal    Killing         pod/web-pod   Stopping container nginx
4m59s       Warning   FailedKillPod   pod/web-pod   error killing pod: failed to "KillContainer" for "nginx" with KillContainerError: "rpc error: code = Unknown desc = Error response from daemon: No such container: 584b125bb4ed8de4b434234c7f9227c471bd2be49dde999a4d37f3e17c9d2f93"
3m44s       Normal    Scheduled       pod/web-pod   Successfully assigned default/web-pod to docker-desktop
3m44s       Normal    Pulled          pod/web-pod   Container image "nginx:1.17.6-alpine" already present on machine
3m44s       Normal    Created         pod/web-pod   Created container nginx
3m44s       Normal    Started         pod/web-pod   Started container nginx
```

### yaml ファイルの書き方

https://qiita.com/Mayumi_Pythonista/items/a249792da8ef4638e125

### pod に直アクセス

kubectl port-forward [Pod 名] ローカルポート:Pod 内の Pod

```
// pod名 web-pod 内部ポート(containerPort:80の場合)
kubectl port-forward web-pod 8080:80
```

### Deployment の必要性

主に pod のコントロールで以下のような機能がある。

自動修復: Pod が失敗した場合、Deployment は自動的に新しい Pod を起動して置き換えます。
ローリングアップデートとロールバック: Deployment を使用すると、アプリケーションの更新を段階的に行い、問題が発生した場合は以前のバージョンに簡単に戻すことができます。
スケーリング: Deployment を使用すると、Pod の数を簡単に増減させることができます。
したがって、単純なテストや一時的なワークロードでない限り、Deployment を使用することでアプリケーションの管理が容易になり、より堅牢で管理しやすい Kubernetes の環境を構築できます。

基本的には pod の拡張版と考えてよく、deployment があれば pod は不要

適用も通常の apply コマンドで OK

```
kubectl apply -f wordpress_deployment.yml
```

pod の状況

以下のような pod が生成される

```
kubectl get pods
NAME                                    READY   STATUS    RESTARTS   AGE
wordpress-deployment-77788b4998-477d2   1/1     Running   0          20m
wordpress-deployment-77788b4998-mb65b   1/1     Running   0          20m
wordpress-deployment-77788b4998-rj7kj   1/1     Running   0          20m
```

replica set(起動される pod の数)

```
kubectl get rs
NAME                              DESIRED   CURRENT   READY   AGE
wordpress-deployment-77788b4998   3         3         3       17m

kubectl get deployment
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
wordpress-deployment   3/3     3            3           26m

```

仮に pod を`kubectl delete wordpress-deployment-77788b4998-477d2` のようなコマンドで除去しても復活する。

### kubernetes と ECS の課題の違い

| kubernetes | ECS |
| ---------- | --- |

|大規模アプリ向け管理用サーバーが必要設定ファイルが細かい運用コスト高め|サーバー 1 台
管理サーバーは不要
ブラウザから設定も可能|

| kubernetes                                                                         | ECS                                                           |
| ---------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| 大規模アプリ向け<br>管理用サーバーが必要<br>設定ファイルが細かい<br>運用コスト高め | サーバー 1 台<br>管理サーバーは不要<br>ブラウザから設定も可能 |
