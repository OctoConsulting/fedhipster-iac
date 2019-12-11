locals {
  port                       = "${var.port == "" ? "5432" : var.port}"
  master_password            = "${var.password == "" ? random_id.master_password.b64 : var.password}"
  # create_enhanced_monitoring = "${var.create_resources && var.monitoring_interval > 0 ? 1 : 0}"
  # cluster_instance_count     = "${var.create_resources ? var.replica_autoscaling ? var.replica_scale_min : var.replica_count : 0}"
}

# Random string to use as master password unless one is specified
resource "random_id" "master_password" {
  byte_length = 10
}

# data "http" "icanhazip" {
#   url = "http://icanhazip.com"
#}

module "aurora" {
  source                          = "terraform-aws-modules/rds-aurora/aws"
  version                         = "~> 2.0"
  name                            = "${var.cluster_name}"
  engine                          = "${var.engine}"
  port                            = "${local.port}"
  engine_version                  = "${var.engine_version}"
  replica_count                   = 1
  instance_type                   = "${var.instance_class}"
  apply_immediately               = true
  skip_final_snapshot             = true
  db_parameter_group_name         = "${aws_db_parameter_group.aurora_db_postgres10_parameter_group.id}"
  db_cluster_parameter_group_name = "${aws_rds_cluster_parameter_group.aurora_cluster_postgres10_parameter_group.id}"
  #subnets                         = data.aws_subnet_ids.all.ids
  subnets                         = "${aws_subnet.eks.*.id}"
  #vpc_id                         = data.aws_vpc.default.id
  vpc_id                          = "${aws_vpc.eks.id}"
  #vpc_id                         = aws_vpc.eks.id
  vpc_security_group_ids          = ["${aws_security_group.aurora-sg.id}"]
  publicly_accessible             = true
  database_name                   = "app_rds"
  username        = "${var.username}"
  password        = "${local.master_password}"
}

resource "aws_db_parameter_group" "aurora_db_postgres10_parameter_group" {
  name        = "app-aurora-db-postgres10-parameter-group"
  family      = "aurora-postgresql10"
  description = "app-aurora-db-postgres10-parameter-group"
}

resource "aws_rds_cluster_parameter_group" "aurora_cluster_postgres10_parameter_group" {
  name        = "app-aurora-postgres10-cluster-parameter-group"
  family      = "aurora-postgresql10"
  description = "app-aurora-postgres10-cluster-parameter-group"
}

resource "aws_security_group" "aurora-sg" {
  name   = "app-aurora-security-group"
  vpc_id = "${aws_vpc.eks.id}"
  #vpc_id = data.aws_vpc.default.id
  ingress {
    protocol    = "tcp"
    from_port   = "${local.port}"
    to_port     = "${local.port}"
    #cidr_blocks = ["${chomp(data.http.icanhazip.body)}/32"]
    cidr_blocks = ["0.0.0.0/0"]
    security_groups  = ["${aws_security_group.eks-node.id}","${aws_security_group.eks-cluster.id}"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "null_resource" "provisioning" {
#    depends_on = ["module.aurora"]

    # Create DBs for dev, stage, prod
#    provisioner "local-exec" {
#        command = "ansible-playbook -i provisioning/development provisioning/bootstrap-digitalocean.yml"
#    }
#}

variable "cluster_name" {
  default = "app-rds-cluster"
}

variable "instance_class" {
  default = "db.r4.xlarge"
}

variable "engine" {
  default = "aurora-postgresql"
}

variable "engine_version" {
  default = "10.7"
}

variable "port" {
  default = ""
}

variable "username" {
  default = "master"
}

variable "password" {
  default = ""
}

output "cluster_endpoint" {
  description = "The cluster endpoint"
  value       = "${module.aurora.this_rds_cluster_endpoint}"
}

// database_name is not set on `aws_rds_cluster` resource if it was not specified, so can't be used in output
output "cluster_database_name" {
  description = "Name for an automatically created database on cluster creation"
  value       = "${module.aurora.this_rds_cluster_database_name}"
}

output "cluster_master_password" {
  description = "The master password"
  value       = "${module.aurora.this_rds_cluster_master_password}"
}

output "cluster_port" {
  description = "The port"
  value       = "${module.aurora.this_rds_cluster_port}"
}

output "cluster_master_username" {
  description = "The master username"
  value       = "${module.aurora.this_rds_cluster_master_username}"
}

// aws_rds_cluster_instance
output "cluster_instance_endpoints" {
  description = "A list of all cluster instance endpoints"
  value       = "${module.aurora.this_rds_cluster_instance_endpoints}"
}
