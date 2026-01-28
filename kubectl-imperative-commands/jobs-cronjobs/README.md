# Jobs & CronJobs - Imperative Commands

## Jobs

Jobs create one or more Pods and ensure a specified number of them successfully complete.

### Create a Job

```bash
# Basic job
kubectl create job myjob --image=busybox -- echo "Hello World"

# Job with a command
kubectl create job myjob --image=busybox -- sh -c "echo Hello; sleep 5; echo Done"

# Job with specific image
kubectl create job pi-job --image=perl -- perl -Mbignum=bpi -wle 'print bpi(2000)'
```

### Generate YAML (Don't Create)

```bash
# Generate Job YAML
kubectl create job myjob --image=busybox --dry-run=client -o yaml -- echo "hello"

# Save to file
kubectl create job myjob --image=busybox --dry-run=client -o yaml -- echo "hello" > job.yaml
```

### Create Job from CronJob

```bash
# Manually trigger a CronJob (creates a Job)
kubectl create job manual-job --from=cronjob/mycronjob
```

### Job Management

```bash
# List Jobs
kubectl get jobs

# Describe Job
kubectl describe job myjob

# Get Job YAML
kubectl get job myjob -o yaml

# View Job logs
kubectl logs job/myjob

# Delete Job
kubectl delete job myjob

# Delete Job and its Pods
kubectl delete job myjob --cascade=foreground
```

### Job Configuration (YAML Required)

These require editing YAML after generating:

```yaml
spec:
  # Number of successful completions required
  completions: 3

  # How many pods can run in parallel
  parallelism: 2

  # Number of retries before marking failed
  backoffLimit: 4

  # Time limit for the job
  activeDeadlineSeconds: 100

  # Keep finished pods for debugging
  ttlSecondsAfterFinished: 60
```

---

## CronJobs

CronJobs create Jobs on a schedule.

### Cron Schedule Format

```
┌───────────── minute (0-59)
│ ┌───────────── hour (0-23)
│ │ ┌───────────── day of month (1-31)
│ │ │ ┌───────────── month (1-12)
│ │ │ │ ┌───────────── day of week (0-6, Sun=0)
│ │ │ │ │
* * * * *
```

Common patterns:
| Schedule | Description |
|----------|-------------|
| `*/5 * * * *` | Every 5 minutes |
| `0 * * * *` | Every hour |
| `0 0 * * *` | Every day at midnight |
| `0 0 * * 0` | Every Sunday at midnight |
| `0 9 * * 1-5` | Weekdays at 9am |
| `*/15 * * * *` | Every 15 minutes |

### Create a CronJob

```bash
# Run every minute
kubectl create cronjob mycron --image=busybox --schedule="* * * * *" -- echo "Hello"

# Run every 5 minutes
kubectl create cronjob mycron --image=busybox --schedule="*/5 * * * *" -- date

# Run daily at midnight
kubectl create cronjob daily-job --image=busybox --schedule="0 0 * * *" -- echo "Daily task"

# With a shell command
kubectl create cronjob mycron --image=busybox --schedule="*/1 * * * *" -- sh -c "echo $(date): Running"
```

### Generate YAML (Don't Create)

```bash
# Generate CronJob YAML
kubectl create cronjob mycron --image=busybox --schedule="*/5 * * * *" --dry-run=client -o yaml -- echo "hello"

# Save to file
kubectl create cronjob mycron --image=busybox --schedule="*/5 * * * *" --dry-run=client -o yaml -- echo "hello" > cronjob.yaml
```

### CronJob Management

```bash
# List CronJobs
kubectl get cronjobs
kubectl get cj

# Describe CronJob
kubectl describe cronjob mycron

# Get CronJob YAML
kubectl get cj mycron -o yaml

# View last schedule time
kubectl get cj mycron -o jsonpath='{.status.lastScheduleTime}'

# Suspend CronJob (prevent new Jobs)
kubectl patch cronjob mycron -p '{"spec":{"suspend":true}}'

# Resume CronJob
kubectl patch cronjob mycron -p '{"spec":{"suspend":false}}'

# Delete CronJob
kubectl delete cronjob mycron
```

### CronJob Configuration (YAML Required)

```yaml
spec:
  schedule: "*/5 * * * *"

  # What to do if previous job still running
  # Allow (default), Forbid, Replace
  concurrencyPolicy: Forbid

  # How many successful jobs to keep
  successfulJobsHistoryLimit: 3

  # How many failed jobs to keep
  failedJobsHistoryLimit: 1

  # Seconds after missed schedule to still start
  startingDeadlineSeconds: 200

  # Suspend scheduling
  suspend: false

  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: hello
            image: busybox
            command: ["echo", "hello"]
          restartPolicy: OnFailure
```

---

## Common CKAD Scenarios

### Scenario 1: Create Job that runs to completion
```bash
# Create job that echoes date
kubectl create job date-job --image=busybox -- date

# Check completion
kubectl get job date-job

# View output
kubectl logs job/date-job
```

### Scenario 2: Create Job with multiple completions
```bash
# Generate YAML and edit
kubectl create job multi-job --image=busybox --dry-run=client -o yaml -- echo "task" > job.yaml

# Edit to add: completions: 5, parallelism: 2
kubectl apply -f job.yaml
```

### Scenario 3: Create CronJob and manually trigger
```bash
# Create CronJob (runs hourly)
kubectl create cronjob hourly-job --image=busybox --schedule="0 * * * *" -- echo "hourly"

# Manually trigger now
kubectl create job manual-run --from=cronjob/hourly-job

# Check the job
kubectl get jobs
```

### Scenario 4: Debug a failed Job
```bash
# Check Job status
kubectl describe job myjob

# View pod logs
kubectl logs job/myjob

# If pod was deleted, check events
kubectl get events --field-selector involvedObject.name=myjob
```

### Scenario 5: CronJob that doesn't overlap
```bash
# Generate YAML
kubectl create cronjob no-overlap --image=busybox --schedule="* * * * *" --dry-run=client -o yaml -- sleep 90 > cj.yaml

# Edit to add: concurrencyPolicy: Forbid
kubectl apply -f cj.yaml
```

### Scenario 6: Job with backoff limit
```bash
# Generate YAML for a job that might fail
kubectl create job retry-job --image=busybox --dry-run=client -o yaml -- sh -c "exit 1" > job.yaml

# Edit to add: backoffLimit: 3
kubectl apply -f job.yaml

# Watch retries
kubectl get pods -w
```

---

## Restart Policies

| Policy | Use Case |
|--------|----------|
| `Never` | Don't restart failed containers, create new pods |
| `OnFailure` | Restart failed containers in same pod |

**Note**: Jobs only support `Never` or `OnFailure` (not `Always`)

```yaml
spec:
  template:
    spec:
      restartPolicy: OnFailure  # or Never
```

---

## Key Flags Reference

### Job Flags

| Flag | Description |
|------|-------------|
| `--image` | Container image |
| `--from` | Create from CronJob |
| `--dry-run=client` | Don't create |
| `-o yaml` | Output as YAML |

### CronJob Flags

| Flag | Description |
|------|-------------|
| `--image` | Container image |
| `--schedule` | Cron schedule expression |
| `--dry-run=client` | Don't create |
| `-o yaml` | Output as YAML |

---

## Quick Tips

1. **Test CronJob schedule**: Use [crontab.guru](https://crontab.guru) to verify schedules

2. **Quick manual trigger**:
   ```bash
   kubectl create job test-run --from=cronjob/mycron
   ```

3. **View all Jobs from a CronJob**:
   ```bash
   kubectl get jobs --selector=job-name=mycron
   ```

4. **Clean up completed Jobs**:
   ```bash
   kubectl delete jobs --field-selector status.successful=1
   ```

5. **Debug with sleep**: Keep pod alive for debugging
   ```bash
   kubectl create job debug --image=busybox -- sleep 3600
   kubectl exec -it job/debug -- sh
   ```

6. **Check CronJob next run** (approximate):
   ```bash
   kubectl get cj mycron -o jsonpath='{.spec.schedule}'
   ```

7. **Timezone**: CronJobs use kube-controller-manager timezone (usually UTC)
