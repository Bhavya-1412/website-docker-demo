provider "aws"{
    region="ap-south-1"
}

resource "aws_instance" "my-vm-ec2"{
    ami = "ami-0f559c3642608c138"
    instance_type="t3.micro"
    key_name="my-ec2-vm"

    vpc_security_group_ids=["sg-00388752fec6d0690"]

    user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>Welcome to the WebServer</h1>" >> /var/www/html/index.html
    EOF

    tags={
        Name="VMInstance"
    }

}