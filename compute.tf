data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ─── IAM Role for SSM ───
resource "aws_iam_role" "ec2_ssm" {
  name = "lab007-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "lab007-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name
}

# ─── Bastion Host ───
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_1.id
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.ec2_ssm.name

  tags = { Name = "Bastion-Host" }
}

# ─── Web Launch Template ───
resource "aws_launch_template" "web" {
  name_prefix   = "lab007-web-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.web.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm.name
  }

  user_data = base64encode(file("userdata/web.sh"))

  tags = { Name = "lab007-web-lt" }
}

# ─── Backend Launch Template ───
resource "aws_launch_template" "backend" {
  name_prefix   = "lab007-backend-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [aws_security_group.backend.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm.name
  }

  user_data = base64encode(file("userdata/backend.sh"))

  tags = { Name = "lab007-backend-lt" }
}

# ─── Web ASG ───
resource "aws_autoscaling_group" "web" {
  name                = "lab007-web-asg"
  min_size            = 1
  max_size            = 4
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id]

  launch_template {
    id      = aws_launch_template.web.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.web.arn]

  tag {
    key                 = "Name"
    value               = "lab007-web"
    propagate_at_launch = true
  }
}

# ─── Backend ASG ───
resource "aws_autoscaling_group" "backend" {
  name                = "lab007-backend-asg"
  min_size            = 1
  max_size            = 3
  desired_capacity    = 2
  vpc_zone_identifier = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "lab007-backend"
    propagate_at_launch = true
  }
}