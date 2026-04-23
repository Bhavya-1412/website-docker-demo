
provider "aws"{
    region="ap-south-1"
}

terraform{
    backend "s3"{
        bucket="my-state-file-bucket-109"
        key="state/terraform.tfstate"
        region="ap-south-1"
    }
}

resource "aws_s3_bucket" "test_bucket"{
    bucket="my-test-beucket-state-file-109"
}
