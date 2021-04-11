cd _sangaml.MicroDepp/drop

cd terraform

terraform init

terraform plan -var subscription_id="$subscription_id" -var client_id="$client_id" -var client_secret="$client_secret" -var tenant_id="$tenant_id" -var imageversion=$BUILD_BUILDNUMBER -var resource_group_name=$RELEASE_RELEASENAME

yes yes | terraform apply -var subscription_id="$subscription_id" -var client_id="$client_id" -var client_secret="$client_secret" -var tenant_id="$tenant_id" -var imageversion=$BUILD_BUILDNUMBER -var resource_group_name=$RELEASE_RELEASENAME
 
#kubectl --kubeconfig kubeconfig  create namespace rsvp

#kubectl --kubeconfig kubeconfig  apply -f deploy.yaml

kubectl  create namespace rsvp

kubectl  apply -f deploy.yaml

while  [ "$(kubectl --kubeconfig kubeconfig  get po  --selector=app=rsvp -n rsvp -o json | jq ' .items[0].status.containerStatuses[0].ready')" != "true" ]; do sleep 10; done

while  [ "$(kubectl --kubeconfig kubeconfig  get po  --selector=appdb=rsvpdb -n rsvp -o json | jq ' .items[0].status.containerStatuses[0].ready')" != "true" ]; do sleep 10; done

kubectl --kubeconfig kubeconfig  get po  --selector=app=rsvp -n rsvp

kubectl --kubeconfig kubeconfig  get po  --selector=appdb=rsvpdb -n rsvp

kubectl --kubeconfig kubeconfig  get svc  mongodb  -n rsvp

while  [ "$(kubectl --kubeconfig kubeconfig  get svc  rsvp -n rsvp -o json | jq ' .status.loadBalancer.ingress[0].ip')" == null ]; do sleep 10; done

kubectl --kubeconfig kubeconfig  get svc  rsvp -n rsvp

kubectl --kubeconfig kubeconfig  get svc  rsvp  -n rsvp -o json | jq -r ' .status.loadBalancer.ingress[0].ip+":5000"'
