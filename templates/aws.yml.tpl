global:
  cloudProvider: aws
  awsRegion: ${aws_region}

aws-alb-ingress-controller:
  awsVpcID: ${vpc_id}
  clusterName: ${cluster_name}
  awsRegion: ${aws_region}