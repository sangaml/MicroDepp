terraform init
terraform apply
sleep 20m
oc new-project nodeproject
oc new-app --docker-image=sangamlonk.azurecr.io/nodejs:latest --name=nodejs1
