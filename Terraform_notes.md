Terraform
==========

Automating Infrastructure Deployment: 

- Provisioning Resources
- Planning Updates
- Using SOurce COntrol
- Reusing Templates

Use Cases:

- Provision a dev/qa environment in public cloud e.g AWS


Teraform Components:

- Terraform Executables (Written in Golang), download from terraform website and download and invoke the command 
- Terraform File
-- one or more files for desired deployment
- Terraform State Files 
-- created when we run tf files



What  we need in .tf file for creating infra using terraform :

- Variable (Placeholder for holding information that changes as per deployments)
e.g. variable "aws_access_key"

- Providers (components of a cloud provider e.g aws, azure, gcp)
e.g 
  provider "aws"  {
    access_key = "access_key"
    secret_key = "secret_key"
    region = "us-east-1"
  }
- Resource (A kind of resource with its configs : server/DB/app and it can take arguments e.g.  variables)
  e.g. 
 resource "aws_instance" "ex" {
   ami = "ami-c58c1dd3"
   instance_type = "t2.micro"
 }

- Output (If you want to get information from output to verify)

e.g.  It will output the public dns 
 value "aws_public_ip" {
	value = "${aws_instance.ex.public_dns}"
}

- Datasources
- Provisioners (Asking terraform to do some execution remotely or locally, can be command OR scripts)
  e.g.
  provisioner "remote-exec" {
      inline = [
        "sudo yum install nginx -y"
        "sudo service nginx restart"
      ]
    }
- Modules








 ############# COmmands####


 - terraform : show help
 - terraform version
 - terraform plan/apply/


Updating configuration with more resources
==========================================

- Consistent and predictable updates
-- Run same again and again and no more changes (idempotency)



Automating Infrasturucture deployment
================================

- Provisioining Reosurces
- Planning Updated
- Using Resource COntrol
- Reusing templates


Terraform State FIle:
===============

- JSON Format (Only for terraform, dont modify)
-- Resource mapping and metadata (Resource dependency and metadata tree)
-- Locking the file, if multiple people working on same automation
-- Can be stored Local/Remote (terrafomr apply generates the file)
-- e.g. s3, consul,
-- Environment specific (dev state file, production state file)
-- using state file multiple environment canbe provisioned



Terraform Planning
====================

- Inspect the state from tfstate file
- Inspect the configuration file and create dependency graph
- e.g. create a subnet verify the vpc is ready
- Addition and deletion of dependent resources
- It will tell what the change need to happen
- Walks the dependency graph and make the changes
-


Scenario
=========

1 VM in AWS with VPC and subnet and DNS
change to happen - scaling 2 vm of web
-- create a LB and put both VM under the same DNS
-- create 2 subnet in 2 different AZ and assign each to each VM
-- So if one AZ goes down other VM in other AZ in up and running
--

data source : Queires aws and return the available values under the data available variable
  e.g.
  data "aws_availability_zones" "available" {}

  2 subnet under 2 AZ
  here data.aws_availability_zones.available will have the AZs and can be pulled using array like

data.aws_availability_zones.available.name[0]
data.aws_availability_zones.available.name[1]
data.aws_availability_zones.available.name[3]
....

Number of AZs..


1. aws_subnet resource creation requires

public and private subnet ()

-- cidr_block
-- vpc_id
-- availability_zone

2. aws_security_group resource requires

-- name
-- vpc_id
-- ingress   (inbound rules)
-- egress   (outbound rules)

3. aws_resource resource requires

-- name
-- security_groups


4. vpc - contents of the subnet and instances  will go in

5. internet gateway - instances within the vpc to egress out and ingress though gateway

6. ROute table - tell the vpc what to do with the traffic that are not inside vpc and associate the route table with subnets




Demo :

Note : add ignore to file name to be ignored by terraform










