# prepare disk
gcloud compute disks create disk-redis --size=10GB --type=pd-ssd
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk disk-redis
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container redis \
  --machine-type n1-standard-1 \
  --container-image redis:4.0.6 \
  --container-mount-host-path mount-path=/data,host-path=/mnt/disks/data/data,mode=rw \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=disk-redis,device-name=disk-redis,mode=rw,boot=no" \
  --tags allow-redis

# setup firewall
gcloud compute firewall-rules create allow-redis \
  --allow tcp:6379 --target-tags allow-redis
