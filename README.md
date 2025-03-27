# Kubernetes Deployment with Minikube, Docker, and Horizontal Pod Autoscaler

## Overview
This guide explains how to deploy a React application in a Kubernetes cluster using Minikube with two worker nodes. The Docker image is pushed to Docker Hub and used for deployment. The setup includes:
- Creating a **Dockerfile**
- Writing **Kubernetes deployment and service YAML files**
- Setting up **Horizontal Pod Autoscaler (HPA)**
- Configuring a **rolling update** with rollback capabilities
- Viewing logs using `kubectl logs`

---
## **Step 1: Create a Dockerfile**
Create a `Dockerfile` for your React application.

```dockerfile
# Use Node.js as the base image
FROM node:18-alpine AS builder
WORKDIR /app
COPY package.json .
RUN npm install
COPY . .
RUN npm run build

# Use Nginx to serve the build files
FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

---
## **Step 2: Build and Push Image to Docker Hub**
Run the following commands to build and push your image to **Docker Hub**:

```sh
# Build the Docker image
docker build -t ashutoshdash2004/react-app:latest .

# Log in to Docker Hub
docker login

# Push the image to Docker Hub
docker push ashutoshdash2004/react-app:latest
```

---
## **Step 3: Start Minikube with 2 Worker Nodes**
Run the following to start Minikube with two nodes:

```sh
minikube start --nodes=2
```

---
## **Step 4: Create Deployment YAML**
Create a `deployment.yaml` file to deploy the React app with **3 replicas**.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: react-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: react-app
  template:
    metadata:
      labels:
        app: react-app
    spec:
      containers:
        - name: react-app
          image: ashutoshdash2004/react-app:latest
          ports:
            - containerPort: 80
          resources:
            requests:
              cpu: "100m"
            limits:
              cpu: "500m"
```

Apply the deployment:
```sh
kubectl apply -f deployment.yaml
```

---
## **Step 5: Create a Service YAML**
Create `service.yaml` to expose the React app.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: react-app-service
spec:
  selector:
    app: react-app
  type: NodePort
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 31234
```

Apply the service:
```sh
kubectl apply -f service.yaml
```

Check service details:
```sh
kubectl get services
```

---
## **Step 6: Set Up Horizontal Pod Autoscaler (HPA)**
Create `hpa.yaml` to scale pods when CPU usage exceeds 50%.

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: react-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: react-app
  minReplicas: 2
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

Apply HPA:
```sh
kubectl apply -f hpa.yaml
```

Check HPA status:
```sh
kubectl get hpa
```

---
## **Step 7: Rolling Update & Rollback**

### **Rolling Update**
Update the `deployment.yaml` to use a new image version and apply it:
```sh
kubectl set image deployment/react-app react-app=ashutoshdash2004/react-app:v2
```

Monitor update progress:
```sh
kubectl rollout status deployment/react-app
```

### **Rollback in Case of Failure**
Rollback if the new version has issues:
```sh
kubectl rollout undo deployment/react-app
```

---
## **Step 8: View Application Logs**
To check logs of a running pod:
```sh
kubectl logs -f <pod-name>
```
Get pod names:
```sh
kubectl get pods
```

---
## **Step 9: Simulate Load to Trigger Scaling**
Run a stress test inside a temporary pod:
```sh
kubectl run --rm -it --image=busybox stress-test -- /bin/sh
while true; do wget -q -O- http://react-app-service.default.svc.cluster.local; done
```
Monitor pod scaling:
```sh
kubectl get hpa
```

---
## **Conclusion**
By following these steps, you have:
✅ Deployed a React app on Kubernetes
✅ Configured autoscaling
✅ Simulated rolling updates and rollbacks
✅ Verified logs for debugging

Now, your application is production-ready! 🚀
