locals {
    name = "aws-three-tier-wordpress"
    vpc_cidr = "10.0.0.0/16"
    azs      = slice(data.aws_availability_zones.available.names, 0, 2)
}