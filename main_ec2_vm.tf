provider "aws"{
    region="ap-south-1"
}

resource "aws_instance" "my-vm-ec2"{
    ami = "ami-0f559c3642608c138"
    instance_type="t3.micro"
    key_name="my-ec2-vm"

    tags={
        Name="VMInstance"
    }

}