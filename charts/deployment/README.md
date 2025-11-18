# Deployment Helm Chart

Production-ready Helm chart for Kubernetes deployments with modern best practices, security hardening, and comprehensive health checks.

## Features

- **Modern Health Checks**: Startup, liveness, and readiness probes with support for HTTP, TCP, gRPC, and exec
- **Security Hardening**: Pod and container security contexts following best practices
- **Advanced Ingress**: HTTP and gRPC ingress with security headers, CORS, rate limiting, and WebSocket support
- **Multi-Provider Secrets**: ExternalSecret integration for HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, and Azure Key Vault
- **High Availability**: PodDisruptionBudget and affinity/anti-affinity support
- **Network Security**: NetworkPolicy templates for ingress/egress control
- **Autoscaling**: HPA and KEDA support with CPU/memory metrics
- **Flexible Configuration**: ConfigMap support for both key-value pairs and file data
- **Init Containers**: Support for multiple init containers with full configuration

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- (Optional) External Secrets Operator for secret management
- (Optional) NGINX Ingress Controller for ingress features
- (Optional) KEDA for advanced autoscaling

## Installation

### Basic Installation

```bash
helm install my-app ./deployment
```

### Installation with Custom Values

```bash
helm install my-app ./deployment -f my-values.yaml
```

### Installation in Specific Namespace

```bash
helm install my-app ./deployment --namespace production --create-namespace
```

## Configuration

### Image Configuration

```yaml
image:
  repository: nginx
  pullPolicy: Always
  tag: "1.21.0"

imagePullSecrets:
  - name: registry-secret
```

### Service Configuration

```yaml
service:
  type: ClusterIP  # ClusterIP, NodePort, LoadBalancer
  loadBalancerIP: ""  # Only for LoadBalancer type
  ports:
    - port: 80
      targetPort: 8080
      name: http
      protocol: TCP
```

### Health Check Configuration

#### HTTP Probes (Recommended for Web Applications)

```yaml
probes:
  startup:
    enabled: true
    type: http
    http:
      path: /healthz/startup
      port: http
      scheme: HTTP
    initialDelaySeconds: 0
    periodSeconds: 10
    failureThreshold: 30  # 5 minutes max startup time

  liveness:
    enabled: true
    type: http
    http:
      path: /healthz/live
      port: http
    periodSeconds: 10
    failureThreshold: 3

  readiness:
    enabled: true
    type: http
    http:
      path: /healthz/ready
      port: http
    periodSeconds: 5
    failureThreshold: 3
```

#### TCP Probes (For Non-HTTP Services)

```yaml
probes:
  startup:
    enabled: true
    type: tcp
    tcp:
      port: 8080
    periodSeconds: 10
    failureThreshold: 30

  liveness:
    enabled: true
    type: tcp
    tcp:
      port: 8080
    periodSeconds: 10
    failureThreshold: 3

  readiness:
    enabled: true
    type: tcp
    tcp:
      port: 8080
    periodSeconds: 5
    failureThreshold: 3
```

#### gRPC Probes (Kubernetes 1.24+)

```yaml
probes:
  liveness:
    enabled: true
    type: grpc
    grpc:
      port: 9090
      service: ""  # Optional gRPC service name
    periodSeconds: 10
    failureThreshold: 3
```

#### Exec Probes (For Custom Health Checks)

```yaml
probes:
  liveness:
    enabled: true
    type: exec
    exec:
      command:
        - cat
        - /tmp/healthy
    periodSeconds: 10
    failureThreshold: 3
```

### Ingress Configuration

#### Basic HTTP Ingress

```yaml
ingress:
  enabled: true
  className: nginx
  hosts:
    - host: app.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: app-tls-cert
      hosts:
        - app.example.com
```

#### Ingress with Security Headers

```yaml
ingress:
  enabled: true
  className: nginx
  securityHeaders:
    enabled: true
    hsts: true
    hstsMaxAge: 31536000
    hstsIncludeSubdomains: true
    frameOptions: "SAMEORIGIN"
    contentTypeNosniff: true
    xssProtection: "1; mode=block"
    referrerPolicy: "strict-origin-when-cross-origin"
    csp: "default-src 'self'; script-src 'self' 'unsafe-inline';"
```

#### Ingress with CORS

```yaml
ingress:
  enabled: true
  cors:
    enabled: true
    allowOrigin: "https://frontend.example.com"
    allowMethods: "GET, POST, PUT, DELETE, PATCH, OPTIONS"
    allowHeaders: "Authorization, Content-Type"
    allowCredentials: true
    maxAge: 3600
```

#### Ingress with Rate Limiting

```yaml
ingress:
  enabled: true
  rateLimit:
    enabled: true
    rps: 100  # Requests per second per IP
    burst: 200  # Burst capacity
```

#### Ingress with WebSocket Support

```yaml
ingress:
  enabled: true
  websocket:
    enabled: true
```

#### gRPC Ingress

```yaml
ingressGRPC:
  enabled: true
  className: nginx
  grpc:
    timeout: 300
    maxMessageSize: "4m"
    keepaliveTime: 30
    keepaliveTimeout: 10
  hosts:
    - host: grpc.example.com
      paths:
        - path: /
          pathType: Prefix
```

### Secret Management

#### HashiCorp Vault

```yaml
ExternalSecret:
  enabled: true
  type: hashicorp
  kvPath:
    - my-app/production/
  name: vault-backend
```

#### AWS Secrets Manager

```yaml
ExternalSecret:
  enabled: true
  type: aws
  kvPath:
    - my-app-secrets
  name: aws-backend
  region: us-east-1
```

#### GCP Secret Manager

```yaml
ExternalSecret:
  enabled: true
  type: gcp
  kvPath:
    - projects/123456/secrets/my-app
  name: gcp-backend
  projectId: "my-project-id"
```

#### Azure Key Vault

```yaml
ExternalSecret:
  enabled: true
  type: azure
  kvPath:
    - my-app-secret
  name: azure-backend
  vaultUrl: "https://my-vault.vault.azure.net"
```

### ConfigMap Configuration

#### Key-Value Pairs

```yaml
configmap:
  enabled: true
  keyValues:
    LOG_LEVEL: "info"
    API_URL: "https://api.example.com"
```

#### File Data (Mounted as Files)

```yaml
configmap:
  enabled: true
  fileData:
    - fileName: app-config.yaml
      mountPath: /etc/config
      content: |
        server:
          port: 8080
          host: 0.0.0.0
    - fileName: database.conf
      mountPath: /etc/db
      content: |
        host=db.example.com
        port=5432
```

### Environment Variables

```yaml
env:
  - name: NODE_ENV
    value: "production"
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
```

### Init Containers

```yaml
initContainers:
  enabled: true
  containers:
    - name: wait-for-db
      image: busybox:1.35
      command: ["sh"]
      args:
        - -c
        - |
          until nc -z database 5432; do
            echo "Waiting for database..."
            sleep 2
          done
    - name: migration
      image: myapp/migrations:latest
      command: ["npm", "run", "migrate"]
      env:
        - name: DB_HOST
          value: "database"
```

### Resource Configuration

#### Guaranteed QoS (Recommended for Production)

```yaml
resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 1000m  # Same as limits for Guaranteed QoS
    memory: 1Gi
```

#### Burstable QoS

```yaml
resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 500m
    memory: 512Mi
```

### Autoscaling

#### Horizontal Pod Autoscaler (HPA)

```yaml
autoscaling:
  enabled: true
  type: hpa
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 80
  targetMemoryUtilizationPercentage: 80
```

#### KEDA Autoscaling

```yaml
autoscaling:
  enabled: true
  type: keda
  minReplicas: 1
  maxReplicas: 50
  targetCPUUtilizationPercentage: 85
  targetMemoryUtilizationPercentage: 85
```

### High Availability

#### PodDisruptionBudget

```yaml
podDisruptionBudget:
  enabled: true
  minAvailable: 1  # At least 1 pod must be available
  # OR
  # maxUnavailable: 1  # At most 1 pod can be unavailable
```

#### Pod Anti-Affinity

```yaml
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
              - key: app.kubernetes.io/name
                operator: In
                values:
                  - deployment
          topologyKey: kubernetes.io/hostname
```

### Network Policy

```yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: production
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:
        - namespaceSelector: {}
      ports:
        - protocol: TCP
          port: 443  # HTTPS
        - protocol: TCP
          port: 5432  # PostgreSQL
```

### Security Context

By default, the chart runs with minimal security constraints for maximum compatibility. You can harden security as needed:

#### Default (Maximum Compatibility)

```yaml
podSecurityContext: {}
securityContext: {}
# Runs as root user (UID 0) with full privileges
# Compatible with most container images
```

#### Recommended Security Hardening (Non-Root User)

```yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault

securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
      - ALL
```

**Note:** When using `readOnlyRootFilesystem: true`, some applications may need writable directories. Use emptyDir volumes for those:

```yaml
# In your values file
extraVolumes:
  - name: tmp
    emptyDir: {}
  - name: cache
    emptyDir: {}

extraVolumeMounts:
  - name: tmp
    mountPath: /tmp
  - name: cache
    mountPath: /var/cache
```

## Upgrading to 2.0.0

Version 2.0.0 introduces breaking changes. If you're upgrading from 1.x, please note:

### Breaking Changes

1. **Removed Legacy Probe Configuration**: The old `http` and `tcp` probe sections have been removed. Use the new `probes` structure instead.

   **Old (1.x)**:
   ```yaml
   http:
     enabled: true
     path: /health
     port: 8080
   ```

   **New (2.0+)**:
   ```yaml
   probes:
     liveness:
       enabled: true
       type: http
       http:
         path: /health
         port: http
   ```

2. **Removed Global `enabled` Flag**: The top-level `enabled: true` has been removed. Use individual component `enabled` flags instead.

3. **Ingress Restructure**: Ingress configuration has been reorganized into modular sections (securityHeaders, ssl, proxy, cors, etc.).

4. **Data Type Changes**: Some values changed from strings to appropriate types:
   - `autoscaling.minReplicas`: `"1"` → `1`
   - `autoscaling.maxReplicas`: `"3"` → `3`
   - `autoscaling.targetCPUUtilizationPercentage`: `"85"` → `85`

### Migration Guide

1. Review your current values.yaml
2. Update probe configuration to new structure
3. Update autoscaling values to integers
4. Test deployment in non-production environment
5. Deploy to production

## Examples

### Simple Web Application

```yaml
replicaCount: 3

image:
  repository: myapp/web
  tag: "1.0.0"

service:
  ports:
    - port: 80
      targetPort: 8080
      name: http

probes:
  startup:
    enabled: true
    type: http
    http:
      path: /
      port: http
  liveness:
    enabled: true
    type: http
    http:
      path: /
      port: http
  readiness:
    enabled: true
    type: http
    http:
      path: /
      port: http

ingress:
  enabled: true
  hosts:
    - host: myapp.example.com
      paths:
        - path: /
          pathType: Prefix

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 500m
    memory: 512Mi
```

### Microservice with gRPC and Secrets

```yaml
image:
  repository: myapp/api
  tag: "2.1.0"

service:
  ports:
    - port: 9090
      targetPort: 9090
      name: grpc

probes:
  liveness:
    enabled: true
    type: grpc
    grpc:
      port: 9090

ingressGRPC:
  enabled: true
  hosts:
    - host: api.example.com
      paths:
        - path: /

ExternalSecret:
  enabled: true
  type: hashicorp
  kvPath:
    - myapp/production/
  name: vault-backend

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 1000m
    memory: 1Gi

autoscaling:
  enabled: true
  type: keda
  minReplicas: 2
  maxReplicas: 20
  targetCPUUtilizationPercentage: 80

podDisruptionBudget:
  enabled: true
  minAvailable: 1
```

### Background Worker with Init Container

```yaml
image:
  repository: myapp/worker
  tag: "1.5.0"

service:
  ports:
    - port: 8080
      targetPort: 8080
      name: metrics

initContainers:
  enabled: true
  containers:
    - name: wait-for-queue
      image: busybox:1.35
      command: ["sh", "-c"]
      args:
        - "until nc -z rabbitmq 5672; do sleep 2; done"

probes:
  liveness:
    enabled: true
    type: tcp
    tcp:
      port: 8080
  readiness:
    enabled: true
    type: exec
    exec:
      command:
        - /app/check-ready.sh

configmap:
  enabled: true
  keyValues:
    QUEUE_NAME: "tasks"
    WORKERS: "4"

resources:
  limits:
    cpu: 2000m
    memory: 2Gi
  requests:
    cpu: 2000m
    memory: 2Gi
```

## Testing

### Manual Testing

```bash
# Test connectivity to the service
kubectl run -it --rm debug --image=busybox --restart=Never -- wget -O- http://my-app:80
```

### Helm Test

```bash
helm test my-app
```

## Troubleshooting

### Pod Not Starting

1. Check pod status:
   ```bash
   kubectl get pods
   kubectl describe pod <pod-name>
   ```

2. Check logs:
   ```bash
   kubectl logs <pod-name>
   ```

3. Common issues:
   - **ImagePullBackOff**: Check imagePullSecrets configuration
   - **CrashLoopBackOff**: Check startup probe configuration and application logs
   - **Pending**: Check resource requests and node capacity

### Ingress Not Working

1. Check ingress status:
   ```bash
   kubectl get ingress
   kubectl describe ingress <ingress-name>
   ```

2. Verify ingress controller is running:
   ```bash
   kubectl get pods -n ingress-nginx
   ```

3. Check service endpoints:
   ```bash
   kubectl get endpoints
   ```

### Health Checks Failing

1. Test health endpoints manually:
   ```bash
   kubectl port-forward <pod-name> 8080:8080
   curl http://localhost:8080/healthz/live
   ```

2. Adjust probe timing:
   - Increase `initialDelaySeconds` if app needs more startup time
   - Increase `failureThreshold` for flaky checks
   - Increase `timeoutSeconds` for slow responses

## Values Reference

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `1` |
| `image.repository` | Image repository | `nginx` |
| `image.tag` | Image tag | `""` (uses Chart.AppVersion) |
| `image.pullPolicy` | Image pull policy | `Always` |
| `service.type` | Service type | `ClusterIP` |
| `service.ports` | Service ports configuration | See values.yaml |
| `probes.startup.enabled` | Enable startup probe | `true` |
| `probes.liveness.enabled` | Enable liveness probe | `true` |
| `probes.readiness.enabled` | Enable readiness probe | `true` |
| `ingress.enabled` | Enable HTTP ingress | `false` |
| `ingressGRPC.enabled` | Enable gRPC ingress | `false` |
| `ExternalSecret.enabled` | Enable ExternalSecret | `false` |
| `configmap.enabled` | Enable ConfigMap | `false` |
| `resources.limits.cpu` | CPU limit | `250m` |
| `resources.limits.memory` | Memory limit | `250Mi` |
| `autoscaling.enabled` | Enable autoscaling | `true` |
| `autoscaling.type` | Autoscaling type (hpa/keda) | `keda` |
| `podDisruptionBudget.enabled` | Enable PDB | `false` |
| `networkPolicy.enabled` | Enable NetworkPolicy | `false` |

For complete values reference, see [values.yaml](values.yaml).

## Contributing

Issues and pull requests are welcome at [https://github.com/shiftlabs/helm-library](https://github.com/shiftlabs/helm-library).

## License

Apache-2.0

## Maintainers

- ShiftLabs Team - [core@shiftlabs.dev](mailto:core@shiftlabs.dev) - [https://shiftlabs.dev](https://shiftlabs.dev)
