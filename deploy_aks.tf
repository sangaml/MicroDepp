provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=1.22.0"
  subscription_id = "${var.subscription_id}"
  client_id       = "${var.client_id}"
  client_secret   = "${var.client_secret}"
  tenant_id       = "${var.tenant_id}"
}

resource "azurerm_resource_group" "test" {
  name     = "${var.resource_group_name}"
  location = "West US"
}

# Create AKS Cluster
resource "tls_private_key" "aks-key" {
  algorithm   = "RSA"
  rsa_bits  = 2048
}

resource "azurerm_kubernetes_cluster" "myAKSCluster" {
  name                = "myaksCluster"
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
    client_id     = "3f4103d7-e3b7-4c5c-9e02-ef45a842c2a4"
    client_secret = "FC0WPeAw7SZmkosj9GK9EBFQCsYwN54LHuk/FCbkrbA="
  }
  depends_on = ["azurerm_resource_group.test"]
}
resource "local_file" "kubeconfig" {
  content  = "${azurerm_kubernetes_cluster.myAKSCluster.kube_config_raw}"
  filename = "${path.module}/kubeconfig"
}

variable "client_id" {
}
variable "client_secret" {
}
variable "subscription_id" {
}
variable "tenant_id" {
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
#  default = "nodejscluster"
}
variable "aks_k8s_version" {
  default = "1.12.7"
}
variable "imageversion" {
}
resource "local_file" "deploy" {
  content = <<YAML
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: my-nodejs-deployment
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: my-nodejs
    spec:
      containers:
      - name: my-nodejs-container1
#        image: sangamlonk.azurecr.io/node-docker-demo:latest
       image: sangamlonk.azurecr.io/nodejsms:${var.imageversion}
       ports:
        - containerPort: 3000

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
    - protocol: TCP
      port: 3000
      targetPort: 3000
YAML

filename = "${path.module}/deploy.yaml"

}
