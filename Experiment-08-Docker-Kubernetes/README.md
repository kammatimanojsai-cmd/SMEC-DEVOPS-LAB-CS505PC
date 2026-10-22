# Experiment 8 – Integrating Kubernetes and Docker

**Status:** ⏳ **Pending – run on your laptop.** The manifests and `run-k8s.ps1` are ready and the YAML was checked for structure, but no Kubernetes cluster could be started on the machine that prepared this (Kubernetes downloads and Docker Hub were blocked).

## AIM
To build a Docker image, make it available to a local Kubernetes cluster, deploy it, expose it with a Service, and demonstrate scaling and rolling updates.

## Software Requirements
| Software | Install (Windows) |
|---|---|
| Docker Desktop | already used in Experiments 1, 6 and 7 |
| kubectl | `winget install -e --id Kubernetes.kubectl` |
| minikube | `winget install -e --id Kubernetes.minikube` |

### Container runtime note
Kubernetes no longer uses Docker Engine directly (dockershim was removed in v1.24). minikube runs its own node with a CRI-compatible runtime. An image built with `docker build` on Windows is therefore **not** automatically inside the cluster. It is copied in with `minikube image load`, and the manifests use `imagePullPolicy: Never` so Kubernetes uses that loaded copy instead of trying Docker Hub.

## Files
- `k8s/deployment.yaml`: `event-registration` Deployment (2 replicas, rolling update strategy, readiness/liveness probes on `/health`, resource limits)
- `k8s/service.yaml`: NodePort Service `event-registration-svc` (port 80 → container port 5000, nodePort 30050)
- `run-k8s.ps1`: the complete scripted run, with a transcript saved to `evidence/08_k8s_execution.log`

## Procedure
1. Start a cluster: `minikube start --driver=docker`
2. Build the Experiment 1 image: `docker build -t event-registration:1.0 ..\Experiment-01-Flask-Registration`
3. Load it into the cluster: `minikube image load event-registration:1.0`
4. Apply the manifests: `kubectl apply -f k8s\`
5. Verify: `kubectl get deployments,pods,services -o wide`
6. Access the app through the Service: `kubectl port-forward service/event-registration-svc 8085:80`, then open `http://localhost:8085/register`
7. Scale: `kubectl scale deployment event-registration --replicas=4`
8. Rolling update: `kubectl set image deployment/event-registration event-registration=event-registration:1.1`, then `kubectl rollout status`, `kubectl rollout history` and `kubectl rollout undo`

## Execution
```powershell
powershell -ExecutionPolicy Bypass -File .\run-k8s.ps1
# cleanup
kubectl delete -f k8s\
```

## Expected Output
```
NAME                                 READY   UP-TO-DATE   AVAILABLE
deployment.apps/event-registration   2/2     2            2
NAME                                      READY   STATUS    RESTARTS
pod/event-registration-xxxxxxxxx-aaaaa    1/1     Running   0
pod/event-registration-xxxxxxxxx-bbbbb    1/1     Running   0
NAME                             TYPE       CLUSTER-IP     PORT(S)
service/event-registration-svc   NodePort   10.x.x.x       80:30050/TCP
deployment.apps/event-registration scaled          -> 4/4 pods Running
deployment "event-registration" successfully rolled out
```

## Screenshots to Capture
`kubectl get deployments,pods,services` before and after scaling, the app opened through the port-forward in Chrome, and the `rollout history` output.

## Result
*(Fill in after running.)* The Docker image was loaded into a minikube cluster and deployed with 2 replicas behind a NodePort Service. It was then scaled to 4 replicas and updated with a rolling update.

## Viva Questions
1. **What is Kubernetes?** A container orchestration platform that deploys, scales and manages containers across nodes.
2. **What is a Pod?** The smallest deployable unit in Kubernetes: one or more containers that share network and storage.
3. **What does a Deployment do?** It keeps the desired number of pod replicas running and manages rolling updates.
4. **What is a Service?** A stable network endpoint that load-balances traffic to a set of pods (selected by labels).
5. **Why `imagePullPolicy: Never` here?** The image was loaded locally into the cluster and is not in any registry, so Kubernetes must not try to pull it.

## GitHub Link
`https://github.com/kammatimanojsai-cmd/SMEC-DEVOPS-LAB-CS505PC/tree/main/Experiment-08-Docker-Kubernetes`
