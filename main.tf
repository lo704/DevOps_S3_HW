#DevOps Session 3 - Homework

provider "aws" {
  region = "ap-northeast-3" 
}

# 1. AWS creates VPC with cidrblock
resource "aws_vpc" "MyVPC" {
    cidr_block = "10.0.0.0/16"
    tags = {
      Name = "MyVPC"
    }
}

# 2. AWS creates an internet gateway
resource "aws_internet_gateway" "MyIGW" {
  vpc_id = aws_vpc.MyVPC.id
  tags = { 
    Name = "MyIGW"
    }
}

# 3. AWS creates a custom route table

resource "aws_route_table" "Private-RT" {
  vpc_id = aws_vpc.MyVPC.id

  route = []

  tags = {
    Name = "Private-RT"
  }
}

resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.MyVPC.id
#ipv4
  route {
    //route [pub/prv] subnet to gw    
    #route all traffic to gw
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  }
#ipv6
  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.MyIGW.id
  }

  tags = {
    Name = "Public-RT"
  }
} 

# 4. AWS creates 5 subnets (2public-3private)
// 2 Public subnets
resource "aws_subnet" "Public-3A" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-northeast-3a"
    tags = {
      Name = "Public-3A"
  }
}
resource "aws_subnet" "Public-3B" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-northeast-3b"
    tags = {
      Name = "Public-3B"
  }
}
// 3 Private Subnets
resource "aws_subnet" "Private-3A" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-northeast-3a"
    tags = {
      Name = "Private-3A"
  }
}
resource "aws_subnet" "Private-3B" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-northeast-3b"
    tags = {
      Name = "Private-3B"
  }
}

resource "aws_subnet" "Private-3C" {
  vpc_id     = aws_vpc.MyVPC.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-northeast-3c"
    tags = {
      Name = "Private-3C"
  }
}

# 5. AWS Associate Public Subnet with Public-RT Route Table
resource "aws_route_table_association" "Public-3a" {
  subnet_id      = aws_subnet.Public-3A.id
  route_table_id = aws_route_table.Public-RT.id
}

# 5.2 AWS Associate Public Subnet with Public-RT Route Table
resource "aws_route_table_association" "Private-3b" {
  subnet_id      = aws_subnet.Public-3B.id
  route_table_id = aws_route_table.Public-RT.id
}

/*
# 6. AWS Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.first-vpc.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.first-vpc.ipv6_cidr_block]
  }

 ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.first-vpc.ipv6_cidr_block]
  }

 ingress {
    description      = "HTTPS"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    #ipv6_cidr_blocks = [aws_vpc.first-vpc.ipv6_cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" //Any protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web"
  }
}
*/
/*
# 7. AWS creates network Interface with an IP inthe Subnet created in step 4
resource "aws_network_interface" "web-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.0.50"]
  security_groups = [aws_security_group.allow_web.id]
}
*/
/*
# 7.2 AWS creates network Interface with an IP inthe Subnet created in step 4
resource "aws_network_interface" "web-nic2" {
  subnet_id       = aws_subnet.subnet-2.id
  private_ips     = ["10.0.2.50"]
  security_groups = [aws_security_group.allow_web.id]
}
*/
/*
# 8. AWS Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "public-IP" {
  vpc = true

  network_interface         = aws_network_interface.web-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on                = [aws_internet_gateway.gw]
}
*/
/*
# 8.2 AWS Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "private-IP" {
  vpc = true

  network_interface         = aws_network_interface.web-nic2.id
  associate_with_private_ip = "10.0.2.50"
  depends_on                = [aws_internet_gateway.gw]
}
*/

/*
# AWS Create Network Interface2 for Instanace 2
resource "aws_network_interface" "web-nic2" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.60"]
  security_groups = [aws_security_group.allow_web.id]

  attachment {
    instance     = aws_instance.Amazon2-Linux2-server.id
    device_index = 1
  }
}
*/
# 9. AWS Create Server and install/enable apache2
/*
//AWS EC2 instance-1
resource "aws_instance" "Amazon-Linux2-server" {
  ami           = "ami-0ed9277fb7eb570c9"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main-key-us-east-1"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-nic.id
  }
   tags = {
      Name = "AMZ-Server"
  }
  
  //Auto-run bash script
    user_data = <<-EOF
            #!/bin/bash
            yum update -y
            yum install -y httpd
            systemctl start httpd
            systemctl enable httpd
            EOF
}
*/
/*
//AWS EC2 instance-2
resource "aws_instance" "Amazon2-Linux2-server" {
  ami           = "ami-0d03733b08194b561"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  key_name = "main-key-us-east-1"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-nic.id
  }
   tags = {
      Name = "AMZ2-Server"
  }

  //Auto-run bash script
    user_data = <<-EOF
            #!/bin/bash
            echo "Hello World from $(hostname -f)" > /var/www/html/index.html'
            EOF
}

# AWS Creates a EBS Volume
resource "aws_ebs_volume" "storage-1" {
  availability_zone = "us-east-1a"
  size              = 3

  tags = {
    Name = "St1"
  }
}
# AWS Creates a EBS Snapshot
resource "aws_ebs_snapshot" "Storage-1_snap" {
  volume_id = aws_ebs_volume.storage-1.id

  tags = {
    Name = "St1_snap"
  }
}

# Create an AMI that will start a machine whose root device is backed by
# an EBS volume populated from a snapshot. It is assumed that such a snapshot
# already exists with the id "snap-xxxxxxxx".
resource "aws_ami" "example" {
  name                = "St1_snap-ami"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"

  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot.Storage-1_snap.id
    volume_size = 3
  }
}

#AWS Copies AMI to another Region

resource "aws_ami_copy" "st1-send" {
  name              = "St1_eu-ami"
  description       = "A copy of ami-08edec2c44b859f61 for us-east-1"
  source_ami_id     = "ami-08edec2c44b859f61"
  source_ami_region = "us-east-1"
  //destination region issue unresolved
  tags = {
    Name = "AMI-us-eu"
  }
}
*/
