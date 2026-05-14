provider "aws"{
    region = "ap-south-1"
}

resource "aws_security_group" "db_sg"{
    name="db-sg"

    ingress{
        from_port=3306
        to_port=3306
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }

    egress{
        to_port=0
        from_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
    }
}

resource "aws_db_instance" "db"{
    engine="mysql"
    instance_class="db.t3.micro"
    username="admin"
    password="admin123"
    skip_final_snapshot=true
    publicly_accessible=true
    allocated_storage=20

}