terraform init -var subscription_id="$(subscription_id)" -var client_id="$(client_id)" -var client_secret="$(client_secret)" -var tenant_id="$(tenant_id)"
terraform apply -var subscription_id="$(subscription_id)" -var client_id="$(client_id)" -var client_secret="$(client_secret)" -var tenant_id="$(tenant_id)"
sleep 20m
oc new-project nodeproject
oc new-app --docker-image=sangamlonk.azurecr.io/nodejs:latest --name=nodejs1
