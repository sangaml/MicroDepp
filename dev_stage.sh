dockerId=microdepp 
appimageName=rsvp 
dbimageName=mongo
projectname=microdepp

cat _sangaml.MicroDepp/drop/version.txt
oc login $osurl --token=$ostoken	
# oc project $projectname

oc tag $dockerId.azurecr.io/$dbimageName:$BUILD_BUILDNUMBER  $projectname/mongodb:latest 
oc tag $dockerId.azurecr.io/$appimageName:$BUILD_BUILDNUMBER  $projectname/rsvp:latest
