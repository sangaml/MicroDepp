#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -a client_id -b client_secret -c subscription_id -d tenant_id"
   echo -e "\t-a Description of what is client_id"
   echo -e "\t-b Description of what is client_secret"
   echo -e "\t-c Description of what is subscription_id"
   echo -e "\t-d Description of what is tenant_id"
   exit 1 # Exit script after printing help
}

while getopts "a:b:c:d:" opt
do
   case "$opt" in
      a ) client_id="$OPTARG" ;;
      b ) client_secret="$OPTARG" ;;
      c ) subscription_id="$OPTARG" ;;
      d ) tenant_id="$OPTARG" ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty
if [ -z "$client_id" ] || [ -z "$client_secret" ] || [ -z "$subscription_id" ] || [ -z "$tenant_id" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

cd _sangaml.MicroDepp/drop

#az login --service-principal --username "$client_id" --password "$client_secret" --tenant "$tenant_id"
#export ARM_CLIENT_ID="$client_id"
#export ARM_CLIENT_SECRET="$client_secret"
#export ARM_SUBSCRIPTION_ID="$subscription_id"
#export ARM_TENANT_ID="$tenant_id"
cd terraform

terraform init

terraform plan -var subscription_id="$subscription_id" -var tenant_id="$tenant_id" -var client_id="$client_id" -var client_secret="$client_secret" -var imageversion=$BUILD_BUILDNUMBER -var resource_group_name=$RELEASE_RELEASENAME

yes yes | terraform apply -var subscription_id="$subscription_id" -var tenant_id="$tenant_id" -var client_id="$client_id" -var client_secret="$client_secret" -var imageversion=$BUILD_BUILDNUMBER -var resource_group_name=$RELEASE_RELEASENAME
 
kubectl --kubeconfig kubeconfig  create namespace rsvp

kubectl --kubeconfig kubeconfig  apply -f deploy.yaml

while  [ "$(kubectl --kubeconfig kubeconfig  get po  --selector=app=rsvp-app -n rsvp -o json | jq ' .items[0].status.containerStatuses[0].ready')" != "true" ]; do sleep 10; done

while  [ "$(kubectl --kubeconfig kubeconfig  get po  --selector=appdb=rsvpdb -n rsvp -o json | jq ' .items[0].status.containerStatuses[0].ready')" != "true" ]; do sleep 10; done

kubectl --kubeconfig kubeconfig  get po  --selector=app=rsvp-app -n rsvp

kubectl --kubeconfig kubeconfig  get po  --selector=appdb=rsvpdb -n rsvp

kubectl --kubeconfig kubeconfig  get svc  mongodb  -n rsvp

while  [ "$(kubectl --kubeconfig kubeconfig  get svc  rsvp -n rsvp -o json | jq ' .status.loadBalancer.ingress[0].ip')" == null ]; do sleep 10; done

kubectl --kubeconfig kubeconfig  get svc  rsvp-app -n rsvp

kubectl --kubeconfig kubeconfig  get svc  rsvp-app  -n rsvp -o json | jq -r ' .status.loadBalancer.ingress[0].ip+":5000"'
