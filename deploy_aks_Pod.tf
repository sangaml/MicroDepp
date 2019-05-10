provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.22.0"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}
# Create AKS Cluster
resource "tls_private_key" "aks-key" {
  algorithm   = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_kubernetes_cluster" "myAKSCluster" {
  name                = "myAKSCluster"
  location            = "${var.resource_group_location}"
  resource_group_name = "${var.resource_group_name}"
  dns_prefix          = "tppoCluster-dns"
  kubernetes_version  = "${var.aks_k8s_version}"

  linux_profile {
    admin_username = "babauser"

    ssh_key {
      key_data = "${tls_private_key.aks-key.public_key_openssh}"
    }
  }
  agent_pool_profile {
    name            = "agentpool"
    count           = 1
    vm_size         = "Standard_D2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }
}
resource "local_file" "kubeconfig" {
  content  = "${azurerm_kubernetes_cluster.myAKSCluster.kube_config_raw}"
  filename = "${path.module}/kubeconfig"
}
variable "nameregion" {
  default = "West US"
}
variable "nameenvironment" {
  default = "Dev"
}
variable "project" {
  default = "TPPO"
}
variable "resource_group_location" {
  default = "West US"
}
variable "resource_group_name" {
  default = "AvniRG"
}
variable "aks_k8s_version" {
  default = "1.12.7"
}
resource "local_file" "deploy" {
  content = <<YAML
---
apiVersion: v1
kind: Deployment
metadata:
  name: my-nodejs-deployment
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: my-nodeja
    spec:
      containers:
      - name: my-nodejs-container1
        image: sangamlonk.azurecr.io/nodejsapp:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: my-nodejsapp-service
spec:
  selector:
    app: my-nodejs
  type: LoadBalancer
  ports:
    - name: my-nodeja-port
      port: 8080

YAML

filename = "${path.module}/deploy.yml"

}
