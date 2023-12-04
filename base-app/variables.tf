variable "vpc_cidr" {
  default = "10.10.0.0/16"
}

variable "env" {
  default = "prod"
}

variable "region" {
  default = "us-east-1"
}

# variable "public_subnet_cidrs" {
#   default = [
#     "10.10.1.0/24",
#     "10.10.2.0/24",
#     "10.10.3.0/24"
#   ]
# }

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

variable "private_subnet_data" {
  default = {
    "subnet_a" : {
      "name" : "private_db_a"
      "cidr" : "10.10.20.0/24"
      "az" : "us-east-1a"
    }
    "subnet_b" : {
      "name" : "private_db_b"
      "cidr" : "10.10.21.0/24"
      "az" : "us-east-1b"
    }
    "subnet_c" : {
      "name" : "private_db_c"
      "cidr" : "10.10.22.0/24"
      "az" : "us-east-1c"
    }
  }
}
variable "private_subnet_ecs_data" {
  default = {
    "subnet_ecs_a" : {
      "name" : "private_ecs_a"
      "cidr" : "10.10.10.0/24"
      "az" : "us-east-1a"
    }
    "subnet_ecs_b" : {
      "name" : "private_ecs_b"
      "cidr" : "10.10.11.0/24"
      "az" : "us-east-1b"
    }
    "subnet_ecs_c" : {
      "name" : "private_ecs_c"
      "cidr" : "10.10.12.0/24"
      "az" : "us-east-1c"
    }
  }
}

variable "password_keeper_rds" {
  default = "8.0mysql"
}

#{ for k, v in var.subnets_data : k => v}
