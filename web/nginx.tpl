events{
    worker_connections 1024;
}

http{
    server{
        server_name localhost;
        listen {{PORT}};
        proxy_set_header    Host    $host;
        proxy_set_header    X-Real-IP    $remote_addr;
        proxy_set_header    X-Forwarded-Host      $host;
        proxy_set_header    X-Forwarded-Server   $host;
        proxy_set_header    X-Forwarded-For    $proxy_add_x_forwarded_for;
        location / {
            proxy_pass {{APP_SERVER}};
        }
    }
}