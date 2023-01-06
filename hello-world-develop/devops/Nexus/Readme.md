# How To Install and Use Docker on Ubuntu 20.04 with Nexus private registry

## Install docker on Ubuntu 20
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04


## Setup Docker private registry with Nexus
https://www.youtube.com/watch?v=nwThFH8Xt8c&list=WL


## Setup Nginx to proxy request to External Ip port 85 to localhost:5000
```
 server {
    listen   *:85;
    server_name  nx.tehno.top;
  
    # allow large uploads of files
    client_max_body_size 1G;
  
    # optimize downloading files larger than 1G
    #proxy_max_temp_file_size 2G;
  
    location / {
      # Use IPv4 upstream address instead of DNS name to avoid attempts by nginx to use IPv6 DNS lookup
      proxy_pass http://127.0.0.1:5000/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
  }
```

## Resolve an error during docker login
There is an error at jenkins slave node because we did not setup https:
```
docker login 134.209.238.66:85 -u nexusdockeruser 
Password: 
Error response from daemon: Get https://134.209.238.66:85/v2/: http: server gave HTTP response to HTTPS client
```

Adding

{ "insecure-registries":["host:port"] }

to

/etc/docker/daemon.json

did not work for me until I created the file

/etc/default/docker

and put the line

DOCKER_OPTS="--config-file=/etc/docker/daemon.json"

in it and then restarted the docker daemon with

sudo systemctl stop docker and sudo systemctl start docker.

For some reason just doing a sudo systemctl restart docker did not work.
It threw an error about trying to restart the service to quickly. 


!!!!!! Same error from kubelets will be during deploy to k8s  !!!!!
So it's better to order free SSL certificates at https://www.sslforfree.com/ for 90 days 
and setup https for Docker private registry with Nexus