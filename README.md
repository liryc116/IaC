# IaC
Homelab and personal infrastructure configuration as code

## Packer

First, download the plugins with the command:
```
packer init --var-file="../credentials.pkr.hcl" ./ubuntu-server-basic.pkr.hcl
```

To check the files are valid use:
```
packer validate --var-file="../credentials.pkr.hcl" ./ubuntu-server-basic.pkr.hcl
```

To build the template with packer, go to the desired folder and use:
```
packer build --var-file="../credentials.pkr.hcl" ./ubuntu-server-basic.pkr.hcl
```

## Terraform

Terraform can be used to deploy VMs.
I currently use the bpg provider but you can find an example with telmate.

First, download the providers with the command:
```
terraform init
```

Then check the files are valid with:
```
terraform validate
```

Last, create the virtual machines (one by one) like this:
```
terraform apply --auto-approve --parallelism=1
```

I encountered issues with files being locked while duplicating templates.
The parallelism=1 parameter ensures only one VM is deployed at a time.

 ## Kubernetes

To deploy from a subfolder simply use :
```
kubectl apply -k kube/<subfolder>
```
