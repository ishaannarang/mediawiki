variable "aws_region" {
  description = "Name of the Region"
  default =  "us-west-2"
}

variable "azs" {
  description = "A list of availability zones names or ids in the region"
  default = ["us-west-2a", "us-west-2b", "us-west-2c"] 
}

variable "aws_cidr_vpc" {
  description = "The CIDR block for the VPC"
  default = "10.0.0.0/16"
}

variable "aws_cidr_subnet1" {
  description = "CIDR for subnet 1"
  default = "10.0.1.0/24"
}

variable "aws_cidr_subnet2" {
  description = "CIDR for subnet 2"
  default = "10.0.2.0/24"
}

variable "aws_cidr_subnet3" {
  description = "CIDR for subnet 3"
  default = "10.0.3.0/24"
}

variable "aws_sg" {
  description = "Security froup for all instances"
  default = "sg_mediawiki"
}

variable "ip_priv"{
  default = {
    "wiki01"  = "10.0.1.10"
    "wiki02"  = "10.0.2.20"
    "sql"     = "10.0.3.30"
  }
}

variable "aws_tags" {
  description = "Tags for the instances instances"
  default = {
    "webserver1" = "MEDIAWIKI01"
	  "webserver2" = "MEDIAWIKI02"
    "dbserver"   = "SQLPROD01" 
  }
}

variable "keyname" {
  description = "Name of the key"
  default = "mediawiki_key"
}

variable "aws_ami_RHEL" {
  description = "Red Hat Enterprise Linux 7 AMI"
  default= "ami-28e07e50"
}

variable "aws_instance_type" {
  description = "Type of instance to be launched"
  default = "t2.micro"
}