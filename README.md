# What is RudderStack?

[RudderStack](https://rudderstack.com/) is a **customer data pipeline** tool for collecting, routing and processing data from your websites, apps, cloud tools, and data warehouse.

More information on RudderStack can be found [here](https://github.com/rudderlabs/rudder-server).

## Amazon Elastic Kubernetes Service Provisioner

These Terraform scripts provision an Amazon Elastic Kubernetes Service (AWS EKS) cluster in a new VPC and restrict access to other cloud resources owned by you.

# Key features

* Separate VPC

* Separate Kubernetes cluser

## Input parameters

1. Region: AWS region to create the VPC.

Please go through `variables.tf` for other config variables.

## How do you run?

1. Install [Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html) v0.12.0 or later.
1. Open `variables.tf` and checkout the default values for the variables. You can change them if you wish. For example, to change your nodes configuration alter the default values for variables `rudder_node_type` and `rudder_disk_size_gb`.
1. Run `terraform get`.
1. Run `terraform plan`.
1. If the plan looks good, run `terraform apply`. This will create all the needed resources on your AWS.
1. If you would like to use `kubectl`, run ``export KUBECONFIG=`pwd`/kubeconfig_rudder-cluster``

The Kubernetes cluster created by these terraform scripts is by default accessible by rudder. (You can revoke access by following the instructions given at the end.)

## Access for Managed Hosting

For managed hosting, RudderStack would need to access your AWS cluster. Please share the following to enable RudderStack-managed hosting:

1. `rudder_kubeconfig_rudder-cluster`
1. `aws.yml`

## Remove Access To RudderStack

To revoke RudderStack's access to your kubernetes cluster, follow the following steps
1. Remove default values for the variables `map_accounts` and `map_roles` in `variables.tf` file.
1. Run `terraform apply`

## Contact Us

If you come across any issues while configuring or using these scripts, please feel free to start a conversation on our [Slack](https://resources.rudderstack.com/join-rudderstack-slack) channel. We will be happy to help you.
