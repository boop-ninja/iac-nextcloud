# iac-nextcloud

Deploy Nextcloud to Kubernetes

## Setup

1. `git clone`
2. alter backend.tf as needed
3. add terraform.tfvars.json with kube variables
4. `terraform init`
5. `terraform apply`

## Upgrading database

### Backup Database

```sh
kubectl -n $NAMESPACE exec -it -c nextcloud-database $CONTAINER -- /usr/bin/pg_dumpall -U nextcloud > dumpfile
```

### Change Variable

change: `database_image` [to be the postgresql version you wish.](https://hub.docker.com/_/postgres)

### Import Data

```sh
# On System
kubectl -n $NAMESPACE exec -it -c nextcloud-database $CONTAINER -- "$(zsh | bash | sh)"

# In Container
createdb -U nextcloud nextcloud

# On System
kubectl -n $NAMESPACE exec -it -c nextcloud-database $CONTAINER -- env PGPASSWORD="$PG_PASSWORD" psql -U nextcloud < dumpfile
```
