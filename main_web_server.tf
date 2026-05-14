provider "aws"{
    region="ap-south-1"
}

resource "aws_security_group" "my_sg"{
    name="web-sg"

    ingress{
        description="Allow SSH"
        from_port=22
        to_port=22
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }

    ingress{
        description="Allow http"
        from_port=80
        to_port=80
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }
    egress{
        to_port=0
        from_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
    }

    tags={
        Name="Web-SG"
    }
}

resource "aws_instance" "my-vm-ec2"{
    ami = "ami-0f559c3642608c138"
    instance_type="t3.micro"
    key_name="my-ec2-vm"

    vpc_security_group_ids=[aws_security_group.my_sg.id]

    user_data = <<-EOF
    #!/bin/bash
    sudo yum update -y
    sudo yum install httpd -y
    sudo systemctl start httpd
    sudo systemctl enable httpd
    echo "<h1>Welcome to the WebServer</h1>" >> /var/www/html/index.html
    EOF

    tags={
        Name="WebServer"
    }

}