resource "template_dir" "custom_manifests" {
  source_dir      = "${path.module}/templates"
  destination_dir = "${path.module}/rendered"

  vars {
    docker_image = "${var.docker_image}"
    app_name = "${lower(var.environment_name)}"
    cert = "${var.cluster_cert}"
    token = "${var.service_token}"
    host = "${var.k8s_host}"
    node_port = "${var.node_port}"
    node_2_port = "${var.node_2_port}"
    node_3_port = "${var.node_3_port}"
    node_4_port = "${var.node_4_port}"
    node_5_port = "${var.node_5_port}"
    node_6_port = "${var.node_6_port}"
  }
}