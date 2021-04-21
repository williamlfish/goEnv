#!/usr/bin/env bash


# !!! BUNCHA SETUP !!!
set -e
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
colorBad() {
    echo -e "\n\n$RED $1 $NC \n\n"
}
colorGood() {
    echo -e "\n\n$GREEN $1 $NC \n\n"
}

# these are the needed to run the script!!
deps="git gcloud kubectl docker gsutil envsubst"
for cmd in $deps
do
    if ! [ -x "$(command -v $cmd)" ]; then
        colorBad "Error: the command $cmd is missing, please install it"
        exit 1
    fi
done
# !!! BUNCHA SETUP DONE !!!

# !!! SVC_NAME is the only var that needs to be changed for any other repo, but like forrealz, change it to your service name plz! !!!
export SVC_NAME='email-service'

BRANCH=$(git branch --show-current)

split=(${BRANCH//\// })
if [ "$split" != "feature" ]; then
    colorBad "This does not appear to be a feature branch, this script is only meant for feature branches. Adios"
    exit 1
fi
FEATURE=${split[1]}

# this is the actual project id that way we are using the correct env
export PROJECT=$(gcloud projects list --filter="NAME:$FEATURE" --format="csv[no-heading](PROJECT_ID)")

colorGood "deploying $FEATURE to the $PROJECT feature env"

gcloud config set project $PROJECT
gcloud config set container/cluster phoenix
gcloud config set compute/zone us-central1-a
gcloud container clusters get-credentials phoenix
CTX=$(kubectl config current-context)
kubectl config set-context "${CTX}" --namespace=pleiades

CGO_ENABLED=0 GOOS=linux GARCH=amd64 go build ./


MONGO_IP=$(gcloud compute instances list --format="csv[no-heading](INTERNAL_IP)" --filter="name=('NAME' mongo-0)")

export MONGO_ADDRESS="mongodb://$MONGO_IP/admin"
export GIT_TAG=$(git rev-parse --short HEAD)

docker build -t gcr.io/$PROJECT/$SVC_NAME:$GIT_TAG .
gcloud auth configure-docker
docker push gcr.io/$PROJECT/$SVC_NAME:$GIT_TAG


# worth noting this needs to be a globally unique name, aka every bucket name in gcloud needs to be unique across all accounts.
# colorGood "gotta get the env file real quick"
# gsutil cp gs://< pick unique name >/$FEATURE/$SVC_NAME/.env ./.env


colorGood "deploying!!"
for f in $(ls deploy/kube)
do
    if [[ $f == *.yaml ]]
    then
        envsubst < deploy/kube/$f | kubectl apply -f -
    fi
done


 create the secret deployment based on the .env file for the env.
 kubectl create secret generic $SVC_NAME --from-env-file=.env --dry-run=client -o yaml | kubectl apply -f -

# # quick rolly polly for that new app image if deploying from the same git tag.
# kubectl delete po -l=app=$SVC_NAME

colorGood "donzo!"
