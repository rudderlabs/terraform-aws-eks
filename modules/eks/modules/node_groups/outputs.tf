output "aws_auth_roles" {
  description = "Roles for use in aws-auth ConfigMap"
  value = [
    for k, v in local.node_groups_expanded : {
      worker_role_arn = lookup(v, "iam_role_arn", var.default_iam_role_arn)
      platform        = "linux"
    }
  ]
}

output "autoscaling_groups_names" {
  description = "Auto scaling groups created"
  value = {
    for k, v in aws_eks_node_group.workers :
    format("%s-ag-names", k) => [
      for resource in v.resources :
      resource.autoscaling_groups
    ]
  }
}

output "autoscaling_group_scaling_configs" {
  description = "Auto scaling group scaling configs"
  value = {
    for k, v in aws_eks_node_group.workers :
    format("%s-scaling-configs", k) => [
      v.scaling_config
    ]
  }
}
