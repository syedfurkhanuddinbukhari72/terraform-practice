terraform {
  backend "s3" {
    bucket = "terra-tfstate-syed-001"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}