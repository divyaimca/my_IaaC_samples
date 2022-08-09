# terraform-provisioner-example

* 1st generate the aws_access_key and aws_secret_key  in terraform.tfvars file
* 2nd create the key private-public pair 
  generate a key pair in your local system (ssh-keygen -f PriyadarsheeKeys -t rsa) and kepe them under secrets
  under security and network -> key pair -> upload public key 

This example will create an instance in aws, create a sg with port 22 and 80 on, install nginx with remote-exec provisioner, copy a script from local to remote with file provisioner and using local exec it will copy a file back to local system.



Execute below commands in sequence.

* terraform plan -var-file=./secrets/terraform.tfvars 
* terraform apply -var-file=./secrets/terraform.tfvars

Get the public dns from output and use that to access the nginx webserver.
