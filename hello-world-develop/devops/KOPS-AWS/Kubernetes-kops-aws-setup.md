# Setup Kubernetes (K8s) HA Cluster on AWS with Kops

Official documentation: 
https://kops.sigs.k8s.io/getting_started/aws/
https://kops.sigs.k8s.io/operations/high_availability/#advanced-example


0. Create a Route53 private hosted zone (I have domain name tehno.top for tests at uniregistry.com. It's needed to add NS records for frankfurt.k8s subdomain at uniregistry.com. NS records will be provided by AWS Route53 after hosted zone frankfurt.k8s.tehno.top creation. )

   ```sh
   Region --> eu-central-1
   Routeh53 --> hosted zones --> created hosted zone  
   Domain Name: 	frankfurt.k8s.tehno.top  
   Type: Private hosted zone for Amazon VPC
   VPC:    Region --> eu-central-1
   VPC ID: vpc-ca3be0a0 (default vpc for this Region)
    ```
1. Create an IAM user/role  with Route53, EC2, IAM, S3, VPC, AutoScaling full access

( Role description - Allows EC2 instances to call AWS services on your behalf.)
   ```sh
Roles -> KopsKubernetesRole-EC2-IAM-S3-Route53:
AmazonEC2FullAccess
IAMFullAccess
AutoScalingFullAccess
AmazonS3FullAccess
AmazonVPCFullAccess
AmazonRoute53FullAccess
    ```

2. Create Ubuntu (18.04) EC2 instance and Attach IAM role to ubuntu instance
(KOPS station for creation and management Kubernetes cluster)
 Region --> eu-central-1


3. install AWSCLI
   ```sh
    sudo apt-get update
    cd /usr/local/src
    curl https://s3.amazonaws.com/aws-cli/awscli-bundle.zip -o awscli-bundle.zip
    apt install unzip python
    unzip awscli-bundle.zip
    #sudo apt-get install unzip - if you dont have unzip in your system
    ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    ```

4  Install kubectl 
   ```sh
   curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
   ```

5. Install kops on ubuntu instance
   ```sh
    curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
    chmod +x kops-linux-amd64
    sudo mv kops-linux-amd64 /usr/local/bin/kops



7. Create an S3 bucket.

   S3 bucket is used by kubernetes to persist cluster state
   ```sh
    aws s3 mb s3://frankfurt.k8s.tehno.top --region=eu-central-1
   ```
   Enable versioning if needed
   
8. Expose environment variable:
   ```sh
    export KOPS_STATE_STORE=s3://frankfurt.k8s.tehno.top
    export KOPS_CLUSTER_NAME=frankfurt.k8s.tehno.top
   ```
 then kops will use this location KOPS_STATE_STORE by default. 
 I suggest putting this in your bash profile or ~/.bashrc
 
9. Create sshkeys before creating cluster
   ```sh
    ssh-keygen
   ```

10. Create kubernetes cluster definitions on S3 bucket
  ( See example at https://kops.sigs.k8s.io/advanced/download_config/ )

   ```sh
   kops create cluster \
    --cloud aws \
    --node-count 3 \
    --zones "eu-central-1a,eu-central-1b,eu-central-1c" \
    --master-zones "eu-central-1a,eu-central-1b,eu-central-1c" \
    --master-size t2.micro \
    --node-size t2.micro \
    --name ${KOPS_CLUSTER_NAME} \
    --dns-zone frankfurt.k8s.tehno.top \
    --dns private \
    --kubernetes-version 1.18.10 \
    --ssh-public-key /root/.ssh/id_rsa.pub
 
(There should be an odd number of master-zones, for etcd's quorum. 
Hint: Use --zones and --master-zones to declare node zones and master zones separately. 
So unfortunately, at the moment it seems that it is not possible to use kops out of the box in an AWS region with only 2 AZ.)
...
Cluster configuration has been created.

Suggestions:
 * list clusters with: kops get cluster
 * edit this cluster with: kops edit cluster frankfurt.k8s.tehno.top
 * edit your node instance group: kops edit ig --name=frankfurt.k8s.tehno.top nodes
 * edit your master instance group: kops edit ig --name=frankfurt.k8s.tehno.top master-eu-central-1a

Finally configure your cluster with: kops update cluster --name frankfurt.k8s.tehno.top --yes
   ```


11. Create kubernetes cluser
    ```sh
    kops update cluster --name frankfurt.k8s.tehno.top --yes
      ``` 

 
   ```sh
kops has set your kubectl context to frankfurt.k8s.tehno.top
Cluster is starting.  It should be ready in a few minutes.
Suggestions:
 * validate cluster: kops validate cluster --wait 10m
 * list nodes: kubectl get nodes --show-labels
 * ssh to the master: ssh -i ~/.ssh/id_rsa ubuntu@api.frankfurt.k8s.tehno.top
 * the ubuntu user is specific to Ubuntu. If not using Ubuntu please use the appropriate user based on your OS.
 * read about installing addons at: https://kops.sigs.k8s.io/operations/addons.
   ``` 

12. Validate your cluster

     ```sh
      kops validate cluster --wait 10m 
    ``` 


13. To list nodes

   ```sh
   kubectl get nodes
   
   NAME                                             STATUS   ROLES    AGE     VERSION
ip-172-20-101-80.eu-central-1.compute.internal   Ready    node     85s     v1.18.10
ip-172-20-33-83.eu-central-1.compute.internal    Ready    master   2m34s   v1.18.10
ip-172-20-41-151.eu-central-1.compute.internal   Ready    node     96s     v1.18.10
ip-172-20-81-83.eu-central-1.compute.internal    Ready    node     87s     v1.18.10
ip-172-20-84-133.eu-central-1.compute.internal   Ready    master   2m29s   v1.18.10
ip-172-20-98-87.eu-central-1.compute.internal    Ready    master   2m28s   v1.18.10
   ```


14. To test cluster
    ```sh
    kubectl run sample-nginx --image=nginx --replicas=2 --port=80
    kubectl get pods
    ```
    
15. To connect to the master
    ```sh
    ssh ubuntu@api.frankfurt.k8s.tehno.top
    (it will connect to one of master nodes)
    ```    
    
16. To delete cluster
    ```sh
     kops delete cluster --name frankfurt.k8s.tehno.top --yes
    ```

