resource "aws_instance" "pebblepost" {
  ami = "ami-03c983f9003cb9cd1" # Ubuntu Server 22.04 LTS (HVM), SSD Volume Type (64-bit (x86))
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.main-public-1.id}"
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-http.id}"]
  key_name = aws_key_pair.terraform_ec2_key.key_name
}

resource "aws_key_pair" "terraform_ec2_key" {
  key_name = "id_ed25519"
  public_key = "${file("~/.ssh/id_ed25519.pub")}"
}

# an empty resource block
resource "null_resource" "name" {

  # ssh into the ec2 instance
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_ed25519")
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

output "instance_dns" {
  value = join("", ["Hostname: ", aws_instance.pebblepost.public_dns])
}
