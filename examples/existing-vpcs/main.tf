provider "aws" {
  region = "us-west-2"
}

provider "aws" {
  alias  = "oregon"
  region = "us-west-2"
  default_tags {
    tags = {
      category = "network"
    }
  }
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
  default_tags {
    tags = {
      category = "network"
    }
  }
}

module "vpc-peering-multi-region" {
  source  = "registry.terraform.io/opencloudsource/vpc-peering-multi-region/aws"
  version = "1.0.0"
  providers = {
    aws.requester = aws.oregon
    aws.accepter  = aws.singapore
  }

  name             = "oregon-to-singapore"
  requester_vpc_id = "vpc-xxxxxxx"
  accepter_vpc_id  = "vpc-xxxxxxx"
}
