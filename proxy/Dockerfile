FROM ubuntu:14.04

# Set the debconf front end to Noninteractive
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y -q \
	apt-transport-https \
	lsb-release \
	vim \
	wget

COPY etc /etc
COPY usr /usr

ENV USE_NGINX_PLUS=false

RUN cd /etc/ssl/nginx

ARG KEY_FILE_NAME
ARG CERT_FILE_NAME

RUN if [ "$USE_NGINX_PLUS" = "false" ]; then \
	openssl req -nodes -newkey rsa:2048 -keyout /etc/ssl/nginx/certs/$KEY_FILE_NAME -out csr.pem -subj "/C=US/ST=California/L=San Francisco/O=NGINX/OU=Professional Services/CN=proxy" && \
	openssl x509 -req -days 365 -in csr.pem -signkey /etc/ssl/nginx/certs/$KEY_FILE_NAME -out /etc/ssl/nginx/certs/$CERT_FILE_NAME; fi

RUN /usr/local/sbin/install-nginx.sh

# forward request logs to Docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log && \
	ln -sf /dev/stdout /var/log/nginx/error.log

CMD ["nginx","-c","/etc/nginx/nginx-fabric.conf"]

EXPOSE 80 443
