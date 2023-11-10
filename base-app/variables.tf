variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "env" {
  default = "prod"
}

variable "public_subnet_cidrs" {
  default = [
    "10.10.1.0/24",
    "10.10.2.0/24",
    "10.10.3.0/24"
  ]
}

variable "subnets_data" {
  default = {
    "subnet_a" : {
      "name" : "public_a"
      "cidr" : "10.10.1.0/24"
      "az" : "us-east-1a"
    }
    "subnet_b" : {
      "name" : "public_b"
      "cidr" : "10.10.2.0/24"
      "az" : "us-east-1b"
    }
    "subnet_c" : {
      "name" : "public_c"
      "cidr" : "10.10.3.0/24"
      "az" : "us-east-1c"
    }
  }
}
