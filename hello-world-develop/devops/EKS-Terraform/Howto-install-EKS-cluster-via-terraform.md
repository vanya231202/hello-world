# How to install EKS Cluster via terraform
##Install eksctl, awscli, aws-iam-authenticator on Ubuntu

Install the awscli:
`sudo apt install awscli`

Create an IAM account with programmatic access with administrator access to your aws account.

Run aws configure and include your newly created credentials and the region you wish to use. We use eu-west-1 as it supports EKS with Fargate.
```
aws configure
AWS Access Key ID [None]: ......
AWS Secret Access Key [None]: .............
Default region name [None]: eu-central-1
Default output format [None]: 
```

Check the awcli has been configured correctly by running the following command and making sure it returns json with no errors:
`aws ec2 describe-regions`


Download eksctl and move it into /usr/local/bin:
```
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin
```

Check eksctl has installed correctly by running:
`eksctl version`

Download the Amazon EKS vended kubectl binary for your cluster's Kubernetes version from Amazon S3 and install:
Read doc https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html
```
curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.17.9/2020-09-18/bin/darwin/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
```

And install the aws-iam-authenticator:
Read doc https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
```
curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.8/2020-09-18/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv ./aws-iam-authenticator /usr/local/bin
```

## Set up

If you already configured the awscli then you won't have to do this step otherwise make sure you have an administrator user enabled and [programmatic credentials added either in environment variables or in a credentials file.](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

You will also need terraform installed.

## Creating your cluster

Run: 
```
terraform init
```
This will download the relevant provider and resource modules.

Then run:
```
terraform plan
```
This will show you what resources will be created when you apply your terraform configuration.

To apply run:
```
terraform apply
```
And type yes when prompted to apply the configuration.


## Copy created cluster config

```
 ls
kubeconfig_eks-cluster-terraform  main.tf  outputs.tf  terraform.tfstate  variables.tf
 mkdir /home/eks/.kube
 cp kubeconfig_eks-cluster-terraform ~/.kube/config
 kubectl get nodes
```

## Create the secret to be able to use it to pull image from the Nexus docker registry.
```
$ kubectl create secret docker-registry nxregcred \
  --namespace='yournamespace' \ # <-- if needed
  --docker-server='nx.tehno.top' \
  --docker-username='*********' \
  --docker-password='*******' \
  --docker-email='*****'

$ kubectl get secret nxregcred
NAME        TYPE                             DATA   AGE
nxregcred   kubernetes.io/dockerconfigjson   1      102s
```


and add imagePullSecrets in the Deployment.yaml file
```
      imagePullSecrets:
        - name: nxregcred
```


## Deploying containers to your cluster

You can try deploying the Kubernetes configuration by changing to the folder with yml configs and running:
```
kubectl apply -f .
```

To view the application endpoint run:
```
kubectl get svc
```

This will display a url with the loadbalancer allowing access to the hellonode application.

## Deleting your cluster

When you are done with the cluster make sure you run:
```
terraform destroy
```
To clean up the resources you just created.


### !!!ATTENTION!!!
Before start "terraform destroy" you should delete LoadBalancer for EC2 workers (kubectl delete svc hwapp-service).
Load balancer was created not by terraform but by AWS for Service.yml (type: LoadBalancer).
Whithout deleting LoadBalancer will be problem with removing VPC and its elements - internet gateway, subnets.
```
kubectl delete svc hwapp-service
kubectl delete deploy hwapp-deployment
kubectl delete secret nxregcred 
```

