

module "elasticsearch-dev" {
  source                  = "./terraform-aws-elasticsearch"
  namespace               = "eg"
  stage                   = "dev"
  name                    = "app-es"
  //dns_zone_id             = "Z14EN2YD427LRQ"
  security_groups         = ["${aws_security_group.eks-node.id}","${aws_security_group.eks-cluster.id}"]
  //security_groups         = ["sg-036e64164adebb61a"]
  vpc_id                  = "${aws_vpc.eks.id}"
  //vpc_id                  = "vpc-09686eb823bbbbdd4"
  //subnet_ids              = ["subnet-0b66eb4d781fea82f", "subnet-0e73f32d60c38f684"]
  subnet_ids              = "${aws_subnet.eks.*.id}"
  //zone_awareness_enabled  = "true"
  elasticsearch_version   = "6.4"
  instance_type           = "m4.large.elasticsearch"
  ebs_volume_size         = 10
  instance_count          = 2
  encrypt_at_rest_enabled = true
  kibana_subdomain_name   = "kibana-es-dev"

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  depends_on_hack = ["${aws_iam_service_linked_role.es.id}"]

}

module "elasticsearch-stage" {
  source                  = "./terraform-aws-elasticsearch"
  namespace               = "eg"
  stage                   = "stage"
  name                    = "app-es"
  //dns_zone_id             = "Z14EN2YD427LRQ"
  security_groups         = ["${aws_security_group.eks-node.id}","${aws_security_group.eks-cluster.id}"]
  //security_groups         = ["sg-036e64164adebb61a"]
  vpc_id                  = "${aws_vpc.eks.id}"
  //vpc_id                  = "vpc-09686eb823bbbbdd4"
  //subnet_ids              = ["subnet-0b66eb4d781fea82f", "subnet-0e73f32d60c38f684"]
  subnet_ids              = "${aws_subnet.eks.*.id}"
  //zone_awareness_enabled  = "true"
  elasticsearch_version   = "6.4"
  instance_type           = "m4.large.elasticsearch"
  ebs_volume_size         = 10
  instance_count          = 2
  encrypt_at_rest_enabled = true
  kibana_subdomain_name   = "kibana-es-stage"

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  depends_on_hack = ["${aws_iam_service_linked_role.es.id}"]

}

module "elasticsearch-prod" {
  source                  = "./terraform-aws-elasticsearch"
  namespace               = "eg"
  stage                   = "prod"
  name                    = "app-es"
  //dns_zone_id             = "Z14EN2YD427LRQ"
  security_groups         = ["${aws_security_group.eks-node.id}","${aws_security_group.eks-cluster.id}"]
  //security_groups         = ["sg-036e64164adebb61a"]
  vpc_id                  = "${aws_vpc.eks.id}"
  //vpc_id                  = "vpc-09686eb823bbbbdd4"
  //subnet_ids              = ["subnet-0b66eb4d781fea82f", "subnet-0e73f32d60c38f684"]
  subnet_ids              = "${aws_subnet.eks.*.id}"
  //zone_awareness_enabled  = "true"
  elasticsearch_version   = "6.4"
  instance_type           = "m4.large.elasticsearch"
  ebs_volume_size         = 10
  instance_count          = 2
  encrypt_at_rest_enabled = true
  kibana_subdomain_name   = "kibana-es-prod"

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  depends_on_hack = ["${aws_iam_service_linked_role.es.id}"]

}

resource "aws_iam_service_linked_role" "es" {
  aws_service_name = "es.amazonaws.com"
}

resource "aws_elasticsearch_domain_policy" "main-dev" {
  domain_name = "eg-dev-app-es"
  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "${module.elasticsearch-dev.domain_arn}/*"
        }
    ]
}
POLICIES
}

resource "aws_elasticsearch_domain_policy" "main-stage" {
  domain_name = "eg-stage-app-es"
  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "${module.elasticsearch-stage.domain_arn}/*"
        }
    ]
}
POLICIES
}

resource "aws_elasticsearch_domain_policy" "main-prod" {
  domain_name = "eg-prod-app-es"
  access_policies = <<POLICIES
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "${module.elasticsearch-prod.domain_arn}/*"
        }
    ]
}
POLICIES
}


output "domain_endpoint_dev" {
  description = "Domain-specific endpoint for dev used to submit index, search, and data upload requests"
  value       = "${module.elasticsearch-dev.domain_endpoint}"
}

output "domain_hostname_dev" {
  description = "Elasticsearch domain hostname for dev to submit index, search, and data upload requests"
  value       = "${module.elasticsearch-dev.domain_hostname}"
}

output "domain_endpoint_stage" {
  description = "Domain-specific endpoint for stage used to submit index, search, and data upload requests"
  value       = "${module.elasticsearch-stage.domain_endpoint}"
}

output "domain_hostname_stage" {
  description = "Elasticsearch domain hostname for stage to submit index, search, and data upload requests"
  value       = "${module.elasticsearch-stage.domain_hostname}"
}

output "domain_endpoint_prod" {
  description = "Domain-specific endpoint for prod used to submit index, search, and data upload requests"
  value       = "${module.elasticsearch-prod.domain_endpoint}"
}

output "domain_hostname_prod" {
  description = "Elasticsearch domain hostname for prod to submit index, search, and data upload requests"
  value       = "${module.elasticsearch-prod.domain_hostname}"
}
