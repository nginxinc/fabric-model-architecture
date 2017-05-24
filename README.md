# Fabric Model implementation of NGINX Microservices Reference Architecture

The Fabric Model is the most sophisticated of the three models found in the NGINX Microservices Reference Architecture (MRA). It’s internally secure, fast, efficient, and resilient.

The Fabric Model places NGINX as a reverse proxy server in front of application servers, [bringing many benefits](https://www.nginx.com/blog/microservices-reference-architecture-nginx-fabric-model/). The architecture also includes a dedicated NGINX or NGINX Plus server instance in each microservice container. As a result, SSL/TLS security can be implemented for all connections at the microservice level.

Pairing a dedicated NGINX or NGINX Plus instance with each microservice instance in its container has one crucial benefit: you can dynamically create SSL/TLS connections between microservices – connections that are stable, persistent, and therefore fast. An initial SSL/TLS handshake establishes a connection that the microservices application can reuse without further overhead, for scores, hundreds, or thousands of interservice requests.
Read more on the [NGINX blog](https://www.nginx.com/blog/microservices-reference-architecture-nginx-fabric-model/).

## Structure of the Fabric Model Deployment

As indicated in the introduction, you can use open source NGINX or NGINX Plus (or a combination) when deploying the Fabric Model. However, a deployment with open source NGINX is suitable only for test or development use cases, because NGINX does not support service discovery in a way that makes it practical to scale or change the IP addresses of microservices. For more details, see [Deploying with NGINX Plus](#deploying-with-nginx-plus).

The repository consists of a single docker-compose.yml file which creates three containers, each with their own Dockerfile.

### Containers

1. Proxy
    1. The proxy container simply runs NGINX as a reverse proxy. This is the public facing container which handles requests from clients. The requests are routed to the service in the web container

1. Web
    1. The web container is a simple PHP application consisting of a single web page rendered dynamically by a twig template. The content for the template comes from a request that the PHP class makes to the backend container

1. Backend
    1. The backend container is a simple rails app that runs on unicorn. Requests to the ```/backend``` route will render the static content that is defined in the app.rb.

### Prerequisites

* Git
* [Docker](https://www.docker.com/community-edition) 1.13.0+
* NGINX Plus Developer License, if using NGINX Plus in a test or development environment (see [Deploying with NGINX
   Plus](https://github.com/nginxinc/fabric-model-architecture/#deploying-with-nginx-plus))

### <a href="#" id="deploying-with-nginx"></a>Deploying With Open Source NGINX

1. Clone the repository and change into the project directory. You can also download the repository as a ZIP file from [here](https://github.com/nginxinc/fabric-model-architecture/archive/master.zip).

   ```
   git clone git@github.com:nginxinc/fabric-model-architecture.git
   cd fabric-model-architecture
   ```
2. Build the microservice images
   ```
   docker-compose build
   ```
3. Run the application
   ```
   docker-compose up
   ```
4. Wait for log output from the containers to appear in the shell/terminal, indicating that they are up and running.
5. Open a browser and navigate to https://localhost/.
6. The browser will display an SSL warning because the build process creates a self-signed certificate. You can safely dismiss this warning in order to view the main page.

After you dismiss the warning, this appears in the browser window:

![Fabric Model Architecture Homepage](https://github.com/nginxinc/fabric-model-architecture/blob/master/fabric_model_home.png "Fabric Model Home Page")

The shell/terminal window where you ran the ```docker-compose``` command will contain output from the NGINX instances running in the containers, indicating that the instances are handling requests.

To gracefully shutdown the containers and return to the command prompt, type ```ctrl-c```.
Any time you want to restart the containers, use the ```docker-compose``` command in the directory which contains the docker-compose.yml file.

### <a href="#" id="deploying-with-nginx-plus"></a>Deploying with NGINX Plus

For production deployments of the Fabric Model, you need to run NGINX Plus instead of open source NGINX, which does not support service discovery in a way that makes it practical to scale well or adjust to changes in the IP addresses and port numbers of microservices. Specifically, port numbers are usually assigned dynamically to microservices running in containers, and open source NGINX does not support DNS SRV records which include the necessary port information. For a thorough discussion of service discovery in NGINX and NGINX Plus, see our blog.

You can, of course, use NGINX Plus in a development or test environment as well as in production. For development and test use cases, you qualify for a free NGINX Plus Developer License, which you can request [here](https://www.nginx.com/developer-license/). For production use cases, you must have a [paid NGINX Plus subscription](https://www.nginx.com/products/pricing/).

To deploy the Fabric Model with NGINX Plus, first perform the steps in [Deploying with Open Source NGINX](https://github.com/nginxinc/fabric-model-architecture/#deploying-with-nginx-plus) then, perform the following steps:

Download the **nginx-repo.crt** and **nginx-repo.key** files for your NGINX Plus Developer License or subscription, and move them to the root directory of this project. You can then copy both of these files to the `/etc/nginx/ssl` directory of each microservice using the commands below:
```
cp nginx-repo.crt nginx-repo.key proxy/etc/ssl/nginx
cp nginx-repo.crt nginx-repo.key web/etc/ssl/nginx
cp nginx-repo.crt nginx-repo.key backend/etc/ssl/nginx
```
You will also need to modify each Dockerfile to install NGINX Plus. In each Dockerfile, change the value of the `USE_NGINX_PLUS` environment variable from `false` to `true`
```
ENV USE_NGINX_PLUS=true
```
The locations of the Dockerfiles with the environment variable are:
```
proxy/Dockerfile
web/Dockerfile
backend/Dockerfile
```
Copy the certificate and key files to each of the containers in order to make sure that the self-signed certificate warning does not occur:
```
cp <location-of-cert-file> <location-of-key-file> backend/etc/ssl/nginx/certs
cp <location-of-cert-file> <location-of-key-file> proxy/etc/ssl/nginx/certs
cp <location-of-cert-file> <location-of-key-file> web/etc/ssl/nginx/certs
```

***Optional: Configure the names of the certificate and key files***
 
The default names for the certificate and key files are **certificate.pem** and **key.pem**, respectively. If you are using different file names, it is necessary to update some of the configuration files. 

This step is not necessary if the file names are **certificate.pem** and **key.pem**.

Set the name of the certificate and key files under each of the web, backend, and proxy services as build arguments in the docker-compose.yml file:
```
args:
	- CERT_FILE_NAME=<certificate-file-name>
	- KEY_FILE_NAME=<key-file-name>

```
Set the name of the certificate and key files in the ```fabric_config.yml``` of each of the web, backend, and proxy services:
```
cert_file_name: <certificate-file-name>
key_file_name: <key-file-name>

```
Then rebuild all of the microservice images
```
docker-compose build
```
And run the application
```
docker-compose up
```
When you open https://localhost in your browser, you should see the same message and page that is displayed in [Step 6](#step-six) above.

In a browser, navigate to https://localhost/status.html and you will see the [server status information](https://www.nginx.com/products/live-activity-monitoring/). Note that this feature is only available with NGINX Plus.

## Authors
* **Chris Stetson** - [cstetson](https://github.com/cstetson)
* **Ben Horowitz** - [benhorowitz](https://github.com/benhorowitz)
See also the list of [contributors](https://github.com/nginxinc/fabric-model-architecture/contributors) who participated in this project.
## License
This project is licensed under the BSD 2-Clause License - see the [LICENSE](LICENSE) file for details
