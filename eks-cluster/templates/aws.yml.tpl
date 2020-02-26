global:
  cloudProvider: aws
  awsRegion: ${aws_region}
  clusterName: ${cluster_name}

aws-alb-ingress-controller:
  awsVpcID: ${vpc_id}
  clusterName: ${cluster_name}
  awsRegion: ${aws_region}

cluster-autoscaler:
  autoDiscovery:
    clusterName: ${cluster_name}
