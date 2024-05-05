resource "aws_instance" "pebblepost" {
  ami = "ami-03c983f9003cb9cd1" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type (64-bit (x86))
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.main-public-1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-http.id}"]
  key_name = aws_key_pair.terraform_ec2_key.key_name
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name = var.ssh_key_name
  public_key = "${file(var.public_ssh_key_file)}"
}

variable "private_ssh_key_file" {
  type     = string
}

variable "public_ssh_key_file" {
  type     = string
}

variable "ssh_key_name" {
  type     = string
}

# an empty resource block
resource "null_resource" "name" {

  # ssh into the ec2 instance
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_ssh_key_file)
    host        = aws_instance.pebblepost.public_ip
  }

  # copy the deployment.sh from your computer to the ec2 instance
  provisioner "file" {
    source      = "deployment.sh"
    destination = "/home/ubuntu/deployment.sh"
  }

  # set permissions and run the build_docker_image.sh file
  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ubuntu/deployment.sh",
      "sh /home/ubuntu/deployment.sh",
    ]
  }

  # wait for ec2 to be created
  depends_on = [aws_instance.pebblepost]

}

# print the IP and hostname of the EC2 instance
output "instance_ip" {
  value = join("", ["IP: ", aws_instance.pebblepost.public_ip])
}

output "instance_url" {
  value = join("", ["URL: ", "http://", aws_instance.pebblepost.public_dns, "/next-fibonacci?number=3"])
}
