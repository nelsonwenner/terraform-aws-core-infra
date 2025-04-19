
resource "aws_key_pair" "key-pair" {
  key_name   = var.key_name
  public_key = file("${var.public_ssh_key_path}")
}

resource "aws_instance" "app" {
  ami                         = "ami-084568db4383264d4"
  instance_type               = "t2.micro"
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  associate_public_ip_address = var.associate_public_ip_address
  vpc_security_group_ids      = [var.security_group_id]

  tags = {
    Name = "infra-${var.environment}-ec2-${var.ec2_private_or_public}"
  }
}
