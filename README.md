## Overview

A terraform repository, which by default is used to create a single Nginx load balancer and two application servers. The configuration is managed by puppet.

Nginx Node Components:

Nginx
Consul
Consul-Template

Consul, the service discovery tool is used in conjunction with consul-template to dynamically change the nginx configuration so that it load balances correctly. This will be dependent on the health of the application server.

Application Server Components:

Go
Consul

Go runs a simple web application which is running on port 8484. Consul runs various health checks to determine the nodes state, used by the load balancer

### Usage

```
1. Add credentials (access and secret key) and public key to terraform.tfvars:

  a. Create credentials: http://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSGettingStartedGuide/AWSCredentials.html

  b. Create private & public key:

     openssl genrsa -out /keys/server.pem 2048

     chmod 0600 server.pem

     ssh-keygen -y -f /keys/server.pem > /keys/server.pub

2. Run terraform from base directory:

    Build Environment:

    terraform apply

    Destroy Environment:

    terraform destroy

    Rebuild Node:

    terraform taint --module=nginx aws_instance.nginx
    terraform taint --module=appserver aws_instance.appserver.0

3. Checking Environment functionality

   terraform output nginx_publicdns

   curl http://<nginx public dns>

```
