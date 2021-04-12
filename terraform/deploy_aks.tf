provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  version = "=2.51.0"
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
    vm_size         = "Standard_D1"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
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
}
variable "aks_k8s_version" {
  default = "1.18.14"
}
variable "imageversion" {
}
resource "local_file" "deploy" {
  content = <<YAML
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: rsvp-db
  namespace: rsvp 
spec: 
  replicas: 1
  template:
    metadata:
      labels:
        appdb: rsvpdb
    spec: 
      containers:
      - name: rsvpd-db
        image: microdepp.azurecr.io/mongo:${var.imageversion}
        env:
        - name: MONGODB_DATABASE
          value: rsvpdata
        ports:
        - containerPort: 27017
---
apiVersion: v1
kind: Service
metadata:
  name: mongodb
  namespace: rsvp 
  labels:
    app: rsvpdb
spec:
  ports:
  - port: 27017
    protocol: TCP
  selector:
    appdb: rsvpdb
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: rsvp
  namespace: rsvp   
spec: 
  replicas: 1
  template:
    metadata:
      labels:
        app: rsvp
    spec:
      containers:
      - name: rsvp-app
        image: microdepp.azurecr.io/rsvp:${var.imageversion}
        env:
        - name: MONGODB_HOST
          value: mongodb
        ports:
        - containerPort: 5000
          name: web-port
---
apiVersion: v1
kind: Service
metadata:
  name: rsvp
  namespace: rsvp 
  labels:
    apps: rsvp
spec:
  type: LoadBalancer
  ports:
  - name: tcp-31081-5000
    nodePort: 31081
    port: 5000
    protocol: TCP
  selector:
    app: rsvp
YAML

filename = "${path.module}/deploy.yaml"

}
