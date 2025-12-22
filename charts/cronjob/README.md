# CronJob Helm Chart

Production-ready Helm chart for Kubernetes CronJobs with modern best practices, security hardening, and comprehensive configuration.

## Features

- **Flexible Scheduling**: Cron expressions with timezone support (Kubernetes 1.25+)
- **Concurrency Control**: Forbid, Allow, or Replace policies for job execution
- **Job Management**: Configurable backoff limits, parallelism, and TTL
- **History Management**: Retain successful and failed job history
- **Security Hardening**: Pod and container security contexts following best practices
- **Multi-Provider Secrets**: ExternalSecret integration for HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, and Azure Key Vault
- **Network Security**: NetworkPolicy templates for ingress/egress control
- **Flexible Configuration**: ConfigMap support for both key-value pairs and file data
- **Init Containers**: Support for multiple init containers with full configuration
- **Resource Management**: CPU and memory limits/requests configuration

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- (Optional) External Secrets Operator for secret management
- (Optional) Kubernetes 1.25+ for timezone support

## Installation

### Basic Installation

```bash
helm install my-cronjob ./cronjob
```

### Installation with Custom Values

```bash
helm install my-cronjob ./cronjob -f my-values.yaml
```

### Installation in Specific Namespace

```bash
helm install my-cronjob ./cronjob --namespace production --create-namespace
```

## Configuration

### CronJob Schedule Configuration

```yaml
cronjob:
  # Cron schedule expression
  schedule: "0 0 * * *"  # Daily at midnight

  # Timezone (Kubernetes 1.25+)
  timeZone: "America/New_York"

  # Concurrency policy
  concurrencyPolicy: Forbid  # Forbid, Allow, or Replace

  # Job history limits
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1

  # Starting deadline in seconds
  startingDeadlineSeconds: 200

  # Suspend flag
  suspend: false
```

#### Common Cron Schedule Examples

```yaml
# Every 5 minutes
schedule: "*/5 * * * *"

# Every hour
schedule: "0 * * * *"

# Every 2 hours
schedule: "0 */2 * * *"

# Daily at midnight
schedule: "0 0 * * *"

# Daily at 3:30 AM
schedule: "30 3 * * *"

# Weekly on Sunday at midnight
schedule: "0 0 * * 0"

# Monthly on the 1st at midnight
schedule: "0 0 1 * *"

# Weekdays at 9 AM
schedule: "0 9 * * 1-5"
```

### Job Template Configuration

```yaml
job:
  # Restart policy: OnFailure or Never
  restartPolicy: OnFailure

  # Number of retries before marking as failed
  backoffLimit: 3

  # Number of successful completions
  completions: 1

  # Number of pods running in parallel
  parallelism: 1

  # Active deadline in seconds
  activeDeadlineSeconds: 3600  # 1 hour

  # TTL for finished jobs (auto-cleanup)
  ttlSecondsAfterFinished: 86400  # 24 hours
```

### Image Configuration

```yaml
image:
  repository: busybox
  pullPolicy: Always
  tag: "1.36"

imagePullSecrets:
  - name: registry-secret
```

### Container Command and Arguments

```yaml
# Override the image entrypoint
command:
  - "/bin/sh"
  - "-c"

# Override the image CMD
args:
  - |
    echo "Starting batch job..."
    date
    # Your job logic here
    echo "Job completed successfully!"
```

### Environment Variables

```yaml
env:
  - name: JOB_TYPE
    value: "backup"
  - name: TARGET_ENV
    value: "production"
  - name: DATABASE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
```

### External Secrets (HashiCorp Vault)

```yaml
ExternalSecret:
  enabled: true
  type: hashicorp
  name: vault-backend
  kvPath:
    - prod/batch-job-secrets
```

### External Secrets (AWS Secrets Manager)

```yaml
ExternalSecret:
  enabled: true
  type: aws
  name: aws-secrets-backend
  region: us-east-1
  kvPath:
    - prod/batch-job
```

### External Secrets (GCP Secret Manager)

```yaml
ExternalSecret:
  enabled: true
  type: gcp
  name: gcp-secrets-backend
  projectId: "my-project-123"
  kvPath:
    - prod-batch-job-secrets
```

### External Secrets (Azure Key Vault)

```yaml
ExternalSecret:
  enabled: true
  type: azure
  name: azure-keyvault-backend
  vaultUrl: "https://my-vault.vault.azure.net"
  kvPath:
    - prod-batch-job
```

### ConfigMap Configuration

#### Key-Value ConfigMap

```yaml
configmap:
  enabled: true
  keyValues:
    LOG_LEVEL: "info"
    BATCH_SIZE: "100"
    RETRY_ATTEMPTS: "3"
```

#### File-Based ConfigMap

```yaml
configmap:
  enabled: true
  fileData:
    - fileName: config.yaml
      mountPath: /etc/config
      content: |-
        database:
          host: postgres.prod.svc.cluster.local
          port: 5432
        settings:
          timeout: 30
          max_connections: 10
    - fileName: script.sh
      mountPath: /scripts
      content: |-
        #!/bin/bash
        echo "Running custom script..."
        # Your script logic
```

### Init Containers

```yaml
initContainers:
  enabled: true
  containers:
    - name: wait-for-db
      image: busybox:1.36
      command: ["sh", "-c"]
      args:
        - |
          until nc -z postgres.prod.svc.cluster.local 5432; do
            echo "Waiting for database..."
            sleep 2
          done
    - name: setup-workspace
      image: alpine:latest
      command: ["sh", "-c"]
      args:
        - |
          mkdir -p /workspace/temp
          chmod 777 /workspace/temp
      volumeMounts:
        - name: workspace
          mountPath: /workspace
```

### Security Context

#### Pod Security Context

```yaml
podSecurityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
```

#### Container Security Context

```yaml
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
      - ALL
```

### Resource Management

```yaml
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi
```

### Network Policy

```yaml
networkPolicy:
  enabled: true
  policyTypes:
    - Ingress
    - Egress
  egress:
    # Allow DNS resolution
    - to:
      - namespaceSelector:
          matchLabels:
            name: kube-system
      ports:
      - protocol: UDP
        port: 53
    # Allow database access
    - to:
      - namespaceSelector:
          matchLabels:
            name: production
        podSelector:
          matchLabels:
            app: postgres
      ports:
      - protocol: TCP
        port: 5432
    # Allow HTTPS to external services
    - to:
      - namespaceSelector: {}
      ports:
      - protocol: TCP
        port: 443
```

### Volume Mounts

```yaml
volumes:
  - name: workspace
    emptyDir: {}
  - name: cache
    emptyDir:
      sizeLimit: 1Gi
  - name: shared-data
    persistentVolumeClaim:
      claimName: shared-storage

volumeMounts:
  - name: workspace
    mountPath: /workspace
  - name: cache
    mountPath: /tmp/cache
  - name: shared-data
    mountPath: /data
```

### Node Scheduling

```yaml
nodeSelector:
  workload-type: batch
  disk-type: ssd

tolerations:
  - key: "batch-workload"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: node-role.kubernetes.io/worker
          operator: In
          values:
          - "true"
```

## Use Cases

### Database Backup Job

```yaml
cronjob:
  schedule: "0 2 * * *"  # Daily at 2 AM
  concurrencyPolicy: Forbid

image:
  repository: postgres
  tag: "15-alpine"

command:
  - "/bin/sh"
  - "-c"

args:
  - |
    pg_dump -h $DB_HOST -U $DB_USER -d $DB_NAME | \
    gzip > /backups/db-$(date +%Y%m%d-%H%M%S).sql.gz

ExternalSecret:
  enabled: true
  type: hashicorp
  kvPath:
    - prod/database-credentials

volumes:
  - name: backups
    persistentVolumeClaim:
      claimName: backup-storage

volumeMounts:
  - name: backups
    mountPath: /backups
```

### Data Processing Job

```yaml
cronjob:
  schedule: "0 */4 * * *"  # Every 4 hours
  concurrencyPolicy: Replace

job:
  backoffLimit: 5
  activeDeadlineSeconds: 7200  # 2 hours max
  ttlSecondsAfterFinished: 3600  # Clean up after 1 hour

image:
  repository: mycompany/data-processor
  tag: "v2.5.0"

resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 1000m
    memory: 2Gi
```

### Cleanup Job

```yaml
cronjob:
  schedule: "0 3 * * 0"  # Weekly on Sunday at 3 AM
  concurrencyPolicy: Forbid

image:
  repository: alpine
  tag: "latest"

command:
  - "/bin/sh"
  - "-c"

args:
  - |
    find /data/logs -type f -mtime +30 -delete
    find /data/temp -type f -mtime +7 -delete
    echo "Cleanup completed"

volumes:
  - name: data
    persistentVolumeClaim:
      claimName: shared-data

volumeMounts:
  - name: data
    mountPath: /data
```

## Monitoring and Debugging

### View CronJob Status

```bash
kubectl get cronjob my-cronjob
```

### View Jobs Created by CronJob

```bash
kubectl get jobs --selector=app.kubernetes.io/instance=my-cronjob
```

### View Pods Created by Jobs

```bash
kubectl get pods --selector=app.kubernetes.io/instance=my-cronjob
```

### View Job Logs

```bash
# Get the latest job
LATEST_JOB=$(kubectl get jobs --selector=app.kubernetes.io/instance=my-cronjob \
  --sort-by=.metadata.creationTimestamp -o name | tail -1)

# View logs
kubectl logs job/$LATEST_JOB
```

### Manually Trigger a Job

```bash
kubectl create job --from=cronjob/my-cronjob manual-job-$(date +%s)
```

### Suspend CronJob

```bash
kubectl patch cronjob my-cronjob -p '{"spec":{"suspend":true}}'
```

### Resume CronJob

```bash
kubectl patch cronjob my-cronjob -p '{"spec":{"suspend":false}}'
```

## Testing

Run Helm tests to verify the CronJob is configured correctly:

```bash
helm test my-cronjob
```

## Uninstallation

```bash
helm uninstall my-cronjob
```

To also delete associated Jobs:

```bash
kubectl delete jobs --selector=app.kubernetes.io/instance=my-cronjob
```

## Version History

- **v1.2.2** - Initial CronJob chart release

## Contributing

Contributions are welcome! Please submit issues and pull requests to the repository.

## License

Apache-2.0

## Support

For issues and questions, please visit: https://github.com/shiftlabs/helm-library/issues
