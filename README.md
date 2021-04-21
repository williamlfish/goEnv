##Quick golang example using env with kube too


you can build and run the apps using the `./bin/start.sh` or `./bin/start-bad.sh`
scripts, this example is very minimal, but I think you can see how you can start to
make it more and more involed. 


There is also a `./bin/deploy.sh` file that should deploy it to kube, if you change line 81 from 
` kubectl create secret generic $SVC_NAME --from-env-file=.env --dry-run=client -o yaml | kubectl apply -f -` to ` kubectl create secret generic $SVC_NAME --from-env-file=.bad.env --dry-run=client -o yaml | kubectl apply -f -`
you should see the same output as you would from running the good/bad scripts
* the deploy file WILL deploy to kube from our GKE env, but only on a real feature branch, you know what I mean :smirk:
<br><br><br>  
  




In the env files you'll notice that the env's are prefixed with GOENV
that is because of the name of the app `err := envconfig.Process("goEnv", &s)` if this was changed too something like `err := envconfig.Process("coolApp", &s)`
then the prefix would be COOLAPP if that makes sense. 


[the env package used here](https://github.com/kelseyhightower/envconfig)

There are deff others, I just picked the first one I remembered :sweat_smile: 