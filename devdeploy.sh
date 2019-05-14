echo $ostoken
echo $(ostoken)
oc login https://api.pro-us-east-1.openshift.com --token=$(ostoken)
oc project nodejsapp
oc tag sangamlonk.azurecr.io/nodejsms:BUILD_BUILDNUMBER  nodejsapp/nodejsms:latest
