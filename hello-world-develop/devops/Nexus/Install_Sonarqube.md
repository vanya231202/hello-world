# How To Install Nexus Sonarqube and  SonaType on one server Ubuntu 20.04


SonaType needs OpenJDK 1.8
SonarQube needs OpenJDK 1.11 and  JRE 11 

Install both version JDK as user root:
```
java -version
apt install openjdk-8-jre-headless
apt install openjdk-11-jre-headless
apt install openjdk-11-jdk
```

SET Default JDK
To set default JDK or switch to OpenJDK enter below command,
```
root@nexus:/opt# update-alternatives --config java
There are 2 choices for the alternative java (providing /usr/bin/java).

  Selection    Path                                            Priority   Status
------------------------------------------------------------
  0            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1111      auto mode
  1            /usr/lib/jvm/java-11-openjdk-amd64/bin/java      1111      manual mode
* 2            /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java   1081      manual mode
```



## Install SonaType Nexus 3 On Ubuntu 20.04 LTS
Follow this instructions:
https://medium.com/@everton.araujo1985/install-sonatype-nexus-3-on-ubuntu-20-04-lts-562f8ba20b98


Setup  OpenJDK 1.8  for SonarType:

```
root@nexus:/opt# cat ~nexus/.bashrc 

JAVA_HOME="/usr/lib/jvm/java-8-openjdk-amd64/"
 export PATH=$JAVA_HOME/bin:$PATH
  export JAVA_HOME
```


## How to Install SonarQube on Ubuntu 20.04 LTS
Follow this instructions:
https://www.fosstechnix.com/how-to-install-sonarqube-on-ubuntu-20-04/


Setup  OpenJDK 1.11  for SonarQube:

```
root@nexus:/opt# cat ~sonar/.bashrc 

JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/"
 export PATH=$JAVA_HOME/bin:$PATH
   export JAVA_HOME
```

Setup OpenJDK 1.11 for sonarqube start script:

```
root@nexus:/opt# vi /opt/sonarqube/bin/linux-x86-64/sonar.sh

JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64/"
export PATH=$JAVA_HOME/bin:$PATH
export JAVA_HOME
```


## Setup Nginx

```
root@nexus:/opt# cat /etc/nginx/nginx.conf 
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
}

http {
	sendfile on;
	tcp_nopush on;

	types_hash_max_size 2048;

	include /etc/nginx/mime.types;
	default_type application/octet-stream;

	ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
	ssl_prefer_server_ciphers on;

	access_log /var/log/nginx/access.log;
	error_log /var/log/nginx/error.log;

	include /etc/nginx/conf.d/*.conf;
	include /etc/nginx/sites-enabled/*;

	##
	# Gzip Settings
    # Disable gzip if use SSL
	##

	#gzip on;


#Settings for NEXUS:

  proxy_send_timeout 120;
  proxy_read_timeout 300;
  proxy_buffering    off;
  keepalive_timeout  5 5;
  tcp_nodelay        on;
  
  server {
    listen   *:80;
    server_name         nx.tehno.top;
    client_max_body_size 1G;
    location / {
      # Use IPv4 upstream address instead of DNS name to avoid attempts by nginx to use IPv6 DNS lookup
      proxy_pass http://127.0.0.1:8081/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
  }

 ssl_session_cache   shared:SSL:10m;
 ssl_session_timeout 10m;

 server {
    listen              *:85;
    listen              *:443 ssl http2 default_server;
    server_name         nx.tehno.top;
    keepalive_timeout   70;
    ssl_certificate     /etc/nginx/ssl/server.crt;
    ssl_certificate_key /etc/nginx/ssl/server.key;
    ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers         HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    client_max_body_size 1G;
    location / {
      # Use IPv4 upstream address instead of DNS name to avoid attempts by nginx to use IPv6 DNS lookup
      proxy_pass http://127.0.0.1:5000/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
  }

  server {
    listen   *:80;
    server_name         sq.tehno.top;
    client_max_body_size 1G;
    location / {
      # Use IPv4 upstream address instead of DNS name to avoid attempts by nginx to use IPv6 DNS lookup
      proxy_pass http://127.0.0.1:9000/;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
  }

}
```

