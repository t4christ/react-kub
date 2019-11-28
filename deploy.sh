docker build -t texplode/client:latest -t texplode/client:$SHA -f  ./docker-react/Dockerfile ./docker-react
docker build -t texplode/server:latest -t texplode/server:$SHA -f  ./server/Dockerfile ./server
docker build -t texplode/worker:latest -t texplode/worker:$SHA -f  ./worker/Dockerfile ./worker

docker push texplode/client:latest
docker push texplode/server:latest
docker push texplode/worker:latest


docker push texplode/client:$SHA
docker push texplode/server:$SHA
docker push texplode/worker:$SHA





# Create user account, service account and clusterbindingrole for kubernetes cluster
# kubectl create serviceaccount --namespace kube-system tiller
# kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller



# certificates to secure the connection between Helm (client side) and Tiller (server side) with SSL/TLS

kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
openssl req -key ca.key.pem -new -x509 -days 7300 -sha256 -out ca.cert.pem -extensions v3_ca
openssl genrsa -out ./tiller.key.pem 4096
openssl genrsa -out ./helm.key.pem 4096
openssl req -key tiller.key.pem -new -sha256 -out tiller.csr.pem
openssl req -key helm.key.pem -new -sha256 -out helm.csr.pem
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in tiller.csr.pem -out tiller.cert.pem -days 365
openssl x509 -req -CA ca.cert.pem -CAkey ca.key.pem -CAcreateserial -in helm.csr.pem -out helm.cert.pem  -days 365
helm init --tiller-tls --tiller-tls-cert ./tiller.cert.pem --tiller-tls-key ./tiller.key.pem --tiller-tls-verify --tls-ca-cert ca.cert.pem

cp ca.cert.pem $HELM_HOME/ca.pem
cp helm.cert.pem $HELM_HOME/cert.pem
cp helm.key.pem $HELM_HOME/key.pem

helm install stable/nginx-ingress --namespace kube-system --set controller.replicaCount=2 --tls
kubectl get svc --all-namespaces

# Apply kubernetes configuration
kubectl apply -f  k8s
kubectl set image deployments/server-deployment server=stephengrider/multi-server:$SHA
kubectl set image deployments/client-deployment client=stephengrider/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=stephengrider/multi-worker:$SHA