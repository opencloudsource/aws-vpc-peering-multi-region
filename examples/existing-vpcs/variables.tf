variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  default     = ""
}

variable "requester_vpc_id" {
  description = "Requester VPC ID"
  type        = string
}

variable "accepter_vpc_id" {
  description = "Accepter VPC ID"
  type        = string
}
