Nginx
-----

You can have one page which contains the list of running containers.

##### Quick Start

1. Run 2 docker-android containers which have port 6081 and 6082 

2. Run docker-nginx 

    ```
    docker run -d --name nginx --network host -v $PWD/conf.d:/etc/nginx/conf.d nginx:1.18.0 
    ```

3. Open [http://127.0.0.1](http://127.0.0.1) from Web-Browser to see the list of running containers OR open ```http://127.0.0.1/container-1/?nginx=&path=/container-1/websockify&view_only=true&password=secr3t``` to see specific container.
