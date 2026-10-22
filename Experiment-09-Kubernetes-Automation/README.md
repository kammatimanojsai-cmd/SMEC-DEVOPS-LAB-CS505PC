# Experiment 9 – Automating the Experiment 7 Application with Kubernetes

**Status:** ⏳ **Pending – run on your laptop** (needs the minikube cluster from Experiment 8). The manifests and script are ready; the Experiment 7 image and its HTTP mode were verified in Docker.

## AIM
To automate the deployment of the containerised Experiment 7 application with Kubernetes manifests (`deployment.yaml`, `service.yaml`) running three replicas, and to manage it with `kubectl`.

## Software Requirements
Docker Desktop, kubectl and minikube (see Experiment 8), and the `hello-app:1.0` image from Experiment 7.

## Adaptation from the Manual
The Experiment 7 program prints "Hello, World!" and **exits**. A Kubernetes Deployment restarts pods whose program exits, so three replicas of it would sit in `CrashLoopBackOff`, and a Service would have nothing to send traffic to.
To fix this, `deployment.yaml` sets `HELLO_HTTP_PORT=8080`. In that case `hello.py` prints the same Hello World lines and then keeps serving "Hello, World!" over HTTP. The pods stay `Running`, pass their readiness probe, and the Service load-balances between them. Plain `docker run hello-app:1.0` (Experiment 7) is unchanged.

## Files
- `deployment.yaml`: Deployment `hello-app`, **3 replicas**, image `hello-app:1.0`, `imagePullPolicy: Never`, readiness probe, resource limits
- `service.yaml`: NodePort Service `hello-app-svc` (80 → 8080, nodePort 30080)
- `run-k8s.ps1`: scripted run, saved to `evidence/09_k8s_execution.log`

## Procedure
1. Make sure minikube is running (`minikube status`).
2. Build and load the image: `docker build -t hello-app:1.0 ..\Experiment-07-Docker-Application` and `minikube image load hello-app:1.0`.
3. Apply the manifests: `kubectl apply -f deployment.yaml -f service.yaml`.
4. Wait for readiness: `kubectl rollout status deployment/hello-app` and check `kubectl get pods` (3/3 Running, READY 1/1).
5. Check the Hello World output in each pod: `kubectl logs <pod>`.
6. Call the Service several times through `kubectl port-forward service/hello-app-svc 8086:80`. Different pod names show the load balancing.
7. Manage the application: `scale` to 5 and back to 3, delete a pod to show self-healing, and `rollout restart`.

## Execution
```powershell
powershell -ExecutionPolicy Bypass -File .\run-k8s.ps1
# cleanup
kubectl delete -f deployment.yaml -f service.yaml
```

## Expected Output
```
NAME        READY   UP-TO-DATE   AVAILABLE
hello-app   3/3     3            3
NAME                         READY   STATUS    RESTARTS
hello-app-xxxxxxxxxx-aaaaa   1/1     Running   0
hello-app-xxxxxxxxxx-bbbbb   1/1     Running   0
hello-app-xxxxxxxxxx-ccccc   1/1     Running   0
$ kubectl logs hello-app-xxxxxxxxxx-aaaaa
Hello, World!
Hello from a Docker container - SMEC DevOps Lab (CS505PC)
...
HTTP mode enabled - listening on port 8080
Hello, World! Served by pod/container: hello-app-xxxxxxxxxx-bbbbb
```
The HTTP mode was verified in Docker on the preparation machine (`evidence/09_docker_precheck.log`): `docker run -e HELLO_HTTP_PORT=8080 -p 8090:8080 hello-app:1.0` stayed `Up` and returned `Hello, World! Served by pod/container: abb8bd038791`.

## Result
*(Fill in after running.)* The Experiment 7 application was deployed by Kubernetes manifests with three ready replicas behind a Service, and was managed with `kubectl` (scaling, self-healing, restart).

## Viva Questions
1. **What is a manifest?** A YAML file that describes the desired state of a Kubernetes object.
2. **What does `replicas: 3` mean?** Kubernetes keeps three identical pods running at all times.
3. **What is a readiness probe?** A check Kubernetes uses to decide whether a pod may receive traffic.
4. **What happens when you delete a pod managed by a Deployment?** The ReplicaSet creates a new pod automatically (self-healing).
5. **`kubectl apply` vs `kubectl create`?** `apply` creates *or updates* objects from a file declaratively; `create` only creates them.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-09-Kubernetes-Automation`
