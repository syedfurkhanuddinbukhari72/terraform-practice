provider "aws" {
    #Old approach - hardcoded region
    #region = "ap-south-1"

    #New approach - using variable for region
    region = var.aws_region
}

resource "aws_key_pair" "my_key_pair" {
    key_name  = "terra automate key"
    public_key = file("terra-automate-key.pub")
}

 resource "aws_vpc" "my_vpc"{
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "terra-custom-vpc"
    }
}

resource "aws_subnet" "my_subnet"{
vpc_id = aws_vpc.my_vpc.id
cidr_block = "10.0.1.0/24"
availability_zone = "ap-south-1a"
map_public_ip_on_launch = true

tags = {
    Name = "terra-public-subnet"
}
}

resource "aws_subnet" "private_subnet"{
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1a"
    tags = {
        Name = "terra-private-subnet"
    }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id

    tags = {
        Name = "terra-igw"
    }
}

resource "aws_route_table" "public_rt" {
    vpc_id = aws_vpc.my_vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_igw.id
    }

    tags = {
        Name = "terra-public-rt"
    }
}

resource "aws_route_table_association" "public_rt_assoc" {
    subnet_id = aws_subnet.my_subnet.id
    route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "my_security_group" {
    name = "terra-security-group" 
    vpc_id = aws_vpc.my_vpc.id
    description = "Inbound and Outbound rules for EC2"

}

resource "aws_vpc_security_group_ingress_rule" "allow_http"{
    security_group_id = aws_security_group.my_security_group.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 80
    to_port = 80
    ip_protocol = "tcp"

}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh"{
    security_group_id = aws_security_group.my_security_group.id
    cidr_ipv4 = "0.0.0.0/0"
    from_port = 22
    ip_protocol = "tcp"
    to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
security_group_id = aws_security_group.my_security_group.id
cidr_ipv4 = "0.0.0.0/0"
ip_protocol = "-1"
}

/*resource "aws_instance" "my_instance"{
    count = 2
    # OLD APPROACH — Hardcoded AMI
    # ami = "ami-07a00cf47dbbc844c"

    ami =  var.ami_id
    #instance_type = "t3.micro"
    instance_type = var.instance_type
    key_name = aws_key_pair.my_key_pair.key_name 
    subnet_id = aws_subnet.my_subnet.id
    user_data = file ("install_nginx.sh")
    vpc_security_group_ids = [
    aws_security_group.my_security_group.id
    ]

    root_block_device {
      volume_size = 10
      volume_type = "gp3"
    }

 
tags = {
    Name = "terra-automate-server"
}

}
*/

# module "dev_app"{
# source = "./my_app_infra_module"
# ami = var.ami_id
# instance_type = var.instance_type
# my_env = "dev" 

# }

module "dev_app" {
    source = "./my_app_infra_module"
    ami = var.ami_id
    instance_type = "t3.micro"
    my_env = "dev"
}

module "stg_app" {
    source = "./my_app_infra_module"
    ami = var.ami_id
    instance_type = "t3.micro"
    my_env = "stg"
    
}

module "prd_app" {
  source = "./my_app_infra_module"

  ami           = var.ami_id
  instance_type = "t3.micro"
  my_env        = "prd"
}



 resource "aws_s3_bucket" "my_bucket" {
     bucket = "terra-storage-syed-001"
     tags = {
        Name = "terra-storage-bucket"
     }
}  

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.my_bucket.id
    versioning_configuration {
        status = "Enabled"
    }

}

resource "aws_s3_bucket_public_access_block" "bucket_pab"{
    bucket = aws_s3_bucket.my_bucket.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true 
}

resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = "terra-tfstate-syed-001"

  tags = {
    Name = "terraform-state-bucket"
  }
}



