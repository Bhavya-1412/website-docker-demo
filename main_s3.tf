provider "aws"{
    region="ap-south-1"
}

resource "aws_s3_bucket" "my_bucket_test"{
    bucket="my-first-bucket-2026-109"

    tags={
        Name="First-S3-Bucket"
        Enviornment="Dev"
    }
}
