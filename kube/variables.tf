variable "environment_name" {
    description = "Used to name and label kubernetes resources"
}

variable "node_port" {
    description = "Port that will provide access to this service through a kubernetes service"
}

variable "node_2_port" {
    description = "Port that will provide access to this service through a kubernetes service"
}

variable "node_3_port" {
    description = "Port that will provide access to this service through a kubernetes service"
}

variable "node_4_port" {
    description = "Port that will provide access to this service through a kubernetes service"
}

variable "node_5_port" {
    description = "Port that will provide access to this service through a kubernetes service"
}

variable "node_6_port" {
    description = "Port that will provide access to this service through a kubernetes service"
}

variable "docker_image" {
    description = "Docker image name that kubernetes will pull"
}

variable "k8s_host" {
    description = "hostname for the kubernetes api server"
}

variable "service_token" {
    description = "Base64 encoded bearer token that will be used to create a kubeconfig file"
}

variable "cluster_cert" {
    description = "Base64 encoded cluster CA certificate that will be used to create a kubeconfig file"
}