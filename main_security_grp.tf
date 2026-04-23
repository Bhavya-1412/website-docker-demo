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