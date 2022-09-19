# AWS VPC Peering Multi Region Module

Terraform module which creates VPC peering connections in the same account between VPCs in different regions.

## Usage

```hcl
module "vpc_peering" {
  source = "opencloudsource/aws-vpc-peering-multi-region/aws"
  providers = {
    aws.requester = aws.oregon
    aws.accepter  = aws.singapore
  }

  name = "oregon-to-singapore"
  requester_vpc_id = "vpc-xxxxxxx"
  accepter_vpc_id  = "vpc-xxxxxxx"
}
```
