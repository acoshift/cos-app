# prepare disk
gcloud compute disks create disk-postgres-dev --size=20GB --type=pd-standard
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk disk-postgres-dev
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container postgres-dev \
  --machine-type f1-micro \
  --container-image postgres:10.1 \
  --container-mount-host-path mount-path=/var/lib/postgresql/data,host-path=/mnt/disks/data/data,mode=rw \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=disk-postgres-dev,device-name=disk-postgres-dev,mode=rw,boot=no" \
  --tags allow-postgres
gcloud compute firewall-rules create allow-postgres \
  --allow tcp:5432 --target-tags allow-postgres
