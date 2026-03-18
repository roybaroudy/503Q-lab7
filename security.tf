resource "aws_security_group" "bastion" {
	name = "Bastion-SG"
	description = "Allow SSH from my IP"
	vpc_id = aws_vpc.main.id
	ingress {
		description = "SSH from my IP"
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = [var.my_ip]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = { Name = "Bastion-SG" }
}

resource "aws_security_group" "alb" {
	name = "ALB-SG"
	description = "Allow HTTP from internet"
	vpc_id = aws_vpc.main.id
	ingress {
		description = "HTTP from anywhere"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = { Name = "ALB-SG" }
}

resource "aws_security_group" "web" {
	name = "Web-SG"
	description = "Allow HTTP from ALB, SSH from bastion"
	vpc_id = aws_vpc.main.id
	ingress {
		description = "HTTP from ALB"
		from_port = 80
		to_port = 80
		protocol = "tcp"
		security_groups = [aws_security_group.alb.id]
	}
	ingress {
		description = "SSH from bastion"
		from_port = 22
		to_port = 22
		protocol = "tcp"
		security_groups = [aws_security_group.bastion.id]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = { Name = "Web-SG" }
}

resource "aws_security_group" "backend" {
	name = "Backend-SG"
	description = "Allow HTTP from web servers, SSH from bastion"
	vpc_id = aws_vpc.main.id
	ingress {
		description = "HTTP from web servers"
		from_port = 3000
		to_port = 3000
		protocol = "tcp"
		security_groups = [aws_security_group.web.id]
	}
	ingress {
		description = "SSH from bastion"
		from_port = 22
		to_port = 22
		protocol = "tcp"
		security_groups = [aws_security_group.bastion.id]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	tags = { Name = "Backend-SG" }
}