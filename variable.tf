variable "organization" {
  type        = string
  description = "This is Terraform Cloud organization"
}

variable "workspace" {
  type        = string
  description = "This is Terraform Cloud workspace name"
}

variable "region" {
  type        = string
  description = "This is AWS service deploy region"
  default     = "ap-northeast-1"
}

variable "availability_zone" {
  type        = string
  description = "This is AWS service deploy AZ"
  default     = "ap-northeast-1a"
}

variable "AWS_ACCESS_KEY_ID" {
  type        = string
  description = "AWS access key"
}

variable "AWS_SECRET_ACCESS_KEY" {
  type        = string
  description = "AWS secret key"
}

variable "instance_ami" {
  type        = string
  description = "AWS AMI, select 64-bit (x86) type"
}

variable "instance_type" {
  type        = string
  description = "AWS EC2 Instance type"
}

variable "instance_key" {
  type        = string
  description = "AWS Instance key-pair name"
}

variable "subnets_cidr_block" {
  type        = list(any)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  description = "Subnets cidr block"
}
