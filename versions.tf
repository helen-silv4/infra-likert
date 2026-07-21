terraform {
    backend "s3" {
        bucket = "infra-likert-tfstate"
        key    = "dynamodb/terraform.tfstat"
        region = "us-east-1"
        use_lockfile = true
        encrypt = true
    }
}