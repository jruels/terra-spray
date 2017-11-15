terraform {
  backend "s3" {
    bucket = "opencamp-kube"
    key    = "demo/terraform.tfstate"
    region = "us-west-1"
  }
}
