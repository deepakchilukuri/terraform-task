variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "project" {
  type    = string
  default = "deepak"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "az" {
  type    = string
  default = "ap-south-1a"
}

variable "allowed_ip_ranges" {
  type    = list(string)
  default = ["0.0.0.0/0"]  # open for SSH + MySQL
}

variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "mysql_root_password" {
  type = string
}

variable "mysql_database" {
  type = string
}
