docker build -t texplode/client:latest -t texplode/client:$SHA -f  ./docker-react/Dockerfile ./docker-react
docker build -t texplode/server:latest -t texplode/server:$SHA -f  ./server/Dockerfile ./server
docker build -t texplode/worker:latest -t texplode/worker:$SHA -f  ./worker/Dockerfile ./worker

docker push texplode/client:latest
docker push texplode/server:latest
docker push texplode/worker:latest


docker push texplode/client:$SHA
docker push texplode/server:$SHA
docker push texplode/worker:$SHA


kubectl apply -f  k8s
kubectl set image deployments/server-deployment server=stephengrider/multi-server:$SHA
kubectl set image deployments/client-deployment client=stephengrider/multi-client:$SHA
kubectl set image deployments/worker-deployment worker=stephengrider/multi-worker:$SHA