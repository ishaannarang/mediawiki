# VPC Resources


######
# VPC
######

resource "aws_vpc" "mw_vpc" {

  cidr_block                       = var.aws_cidr_vpc
  instance_tenancy                 = "default"
  enable_dns_hostnames             = true
  enable_dns_support               = true


  tags = {
    Name = "mw_vpc"
  }
}

###################
# Internet Gateway
###################


resource "aws_internet_gateway" "wiki_igw" {

  vpc_id = aws_vpc.mw_vpc.id
  tags = {
      Name = "Igw"
    }
}

##########
# Subnets
##########


resource "aws_subnet" "mw_public_subnet_2a" {
  vpc_id                    = aws_vpc.mw_vpc.id
  cidr_block                = var.aws_cidr_subnet1
  availability_zone         = element(var.azs, 0)
  map_public_ip_on_launch   =  true

  tags = {
    Name = "mw_public_subnet_2a"
  }
}

resource "aws_subnet" "mw_public_subnet_2b" {
  vpc_id                    = aws_vpc.mw_vpc.id
  cidr_block                = var.aws_cidr_subnet2
  availability_zone         = element(var.azs, 1)
  map_public_ip_on_launch   =  true

  tags = {
    Name = "mw_public_subnet_2b"
  }
}


resource "aws_subnet" "DB_subnet" {
  vpc_id                    = aws_vpc.mw_vpc.id
  cidr_block                = var.aws_cidr_subnet3
  availability_zone         = element(var.azs, 2)
  map_public_ip_on_launch   =  false

  tags = {
    Name = "DB_subnet_2c"
  }
}

################
# Route Table
################

resource "aws_route_table" "mw_rt" {
  vpc_id = aws_vpc.mw_vpc.id

  route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.wiki_igw.id
    }

    tags = {
      Name = "Route table MediaWiki"
    }
}
##########################
# Route table associations
##########################

resource "aws_route_table_association" "subneta" {
  subnet_id       = aws_subnet.mw_public_subnet_2a.id
  route_table_id  = aws_route_table.mw_rt.id
}

resource "aws_route_table_association" "subnetb" {
  subnet_id       = aws_subnet.mw_public_subnet_2b.id
  route_table_id  = aws_route_table.mw_rt.id
}

resource "aws_route_table_association" "DB_subnet" {
  subnet_id       = aws_subnet.DB_subnet.id
  route_table_id  = aws_route_table.mw_rt.id
}

#################
# Security Group
#################

resource "aws_security_group" "mw_sg" {
  name              = "mw_sg"
  description       = "abcd"
  vpc_id            = aws_vpc.mw_vpc.id

 ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }


  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]

  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  

  ingress {
    from_port       = 9100
    to_port         = 9100
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]
  }


  ingress {
    from_port       = 9090
    to_port         = 9090
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]

  }


  ingress {
    from_port       = 9115
    to_port         = 9115
    protocol        = "TCP"
    cidr_blocks     = ["0.0.0.0/0"]

  }


  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "mw_eip_01" {
  instance          = aws_instance.webserver1.id
  vpc               = true
  depends_on        = [aws_internet_gateway.wiki_igw]
}

resource "aws_eip" "mw_eip_02" {
  instance          = aws_instance.webserver2.id
  vpc               = true
  depends_on        = [aws_internet_gateway.wiki_igw]
}

resource "aws_eip" "mw_eip_db" {
  instance          = aws_instance.dbserver.id
  vpc               = true
  depends_on        = [aws_internet_gateway.wiki_igw]
}

###############
# Load Balancer
###############

resource "aws_elb" "mw_elb" {
  name                = "MediaWikiELB"
  subnets             = [aws_subnet.mw_public_subnet_2a.id, aws_subnet.mw_public_subnet_2b.id]
  security_groups     = [aws_security_group.mw_sg.id]
  instances           = [aws_instance.webserver1.id, aws_instance.webserver2.id]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

###########
# Key Pair
###########

resource "tls_private_key" "mw_key" {
  algorithm           = "RSA"
  rsa_bits            = 2048
}

#resource "aws_key_pair" "generated_key" {
 # key_name            = var.keyname
  #public_key          = tls_private_key.mw_key.public_key_openssh

resource "aws_key_pair" "generated_key" { 
  key_name             = var.keyname
  public_key           = file("./mediawiki_key.pub") 

} 

###########
# Instances
###########

resource "aws_instance" "webserver1" {
  ami                         = var.aws_ami_RHEL
  availability_zone           = element(var.azs, 0)
  instance_type               = var.aws_instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.mw_sg.id]
  subnet_id                   = aws_subnet.mw_public_subnet_2a.id 
  private_ip                  = lookup(var.ip_priv,"wiki01")
  associate_public_ip_address = true

  tags = {
    Name    = lookup(var.aws_tags,"webserver1")
    group   = "web"
  }
}

resource "aws_instance" "webserver2" {
  ami                         = var.aws_ami_RHEL
  availability_zone           = element(var.azs, 1)
  instance_type               = var.aws_instance_type
  key_name                    = aws_key_pair.generated_key.key_name
  vpc_security_group_ids      = [aws_security_group.mw_sg.id]
  subnet_id                   = aws_subnet.mw_public_subnet_2b.id
  private_ip                  = lookup(var.ip_priv,"wiki02")
  associate_public_ip_address = true
 

  tags = {
    Name  = lookup(var.aws_tags,"webserver2")
    group = "web"
  }
}

resource "aws_instance" "dbserver" {
  ami                         = var.aws_ami_RHEL
  availability_zone           = element(var.azs, 2)
  instance_type               = var.aws_instance_type
  key_name                    = aws_key_pair.generated_key.key_name 
  vpc_security_group_ids      = [aws_security_group.mw_sg.id]
  subnet_id                   = aws_subnet.DB_subnet.id
  private_ip                  = lookup(var.ip_priv,"sql")
  associate_public_ip_address = true

  tags = {
    Name  = lookup(var.aws_tags,"dbserver")
    group = "db"
  }
}





