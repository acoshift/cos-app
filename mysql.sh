# prepare disk
gcloud compute disks create data-mysql-1 --size=10GB --type=pd-ssd
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk data-mysql-1
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances detach-disk prepare-disk-instance --disk data-mysql-1
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container mysql-1 \
  --machine-type n1-standard-1 \
  --container-image mysql:5.7.22 \
  --container-mount-host-path mount-path=/var/lib/mysql,host-path=/mnt/disks/data/data,mode=rw \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=data-mysql-1,device-name=data-mysql-1,mode=rw,boot=no"