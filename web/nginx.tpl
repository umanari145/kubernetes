error_log  /var/log/nginx/error.log warn;
pid        /var/run/nginx.pid;
events{
    worker_connections 1024;
}

http{

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    access_log  /var/log/nginx/access.log  main;
    server{
        server_name localhost;
        listen {{PORT}};
        location / {
            root   /usr/share/nginx/html;
            index  index.html index.htm;
        }
        proxy_set_header    Host    $host;
        proxy_set_header    X-Real-IP    $remote_addr;
        proxy_set_header    X-Forwarded-Host      $host;
        proxy_set_header    X-Forwarded-Server   $host;
        proxy_set_header    X-Forwarded-For    $proxy_add_x_forwarded_for;
        location /api/v1/ {
            proxy_pass {{APP_SERVER}};
        }
    }
}