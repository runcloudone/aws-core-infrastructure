variable "default_tags" {
  type        = map(string)
  description = "Default tags for AWS that will be attached to each resource"
}

provider "aws" {
  region              = "${aws_region}"
  allowed_account_ids = ["${account_id}"]
  default_tags {
    tags = var.default_tags
  }
}
