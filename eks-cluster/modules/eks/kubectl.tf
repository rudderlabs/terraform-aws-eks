resource "local_file" "kubeconfig" {
  count    = var.write_kubeconfig && var.create_eks ? 1 : 0
  content  = data.template_file.kubeconfig[0].rendered
  filename = substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}kubeconfig_${var.cluster_name}" : var.config_output_path
}

resource "local_file" "rudder_kubeconfig" {
  count    = var.write_kubeconfig && var.create_eks ? 1 : 0
  content  = data.template_file.rudder_kubeconfig[0].rendered
  filename = substr(var.config_output_path, -1, 1) == "/" ? "${var.config_output_path}rudder_kubeconfig_${var.cluster_name}" : var.config_output_path
}
