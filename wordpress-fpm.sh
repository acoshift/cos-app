# prepare disk
gcloud compute disks create data-wordpress --size=10GB --type=pd-ssd
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk data-wordpress
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances detach-disk prepare-disk-instance --disk data-wordpress
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container wordpress \
  --machine-type n1-standard-1 \
  --container-image wordpress:fpm-alpine \
  --container-env="WORDPRESS_DB_HOST=mysql" \
  --container-env="WORDPRESS_DB_PASSWORD=root" \
  --container-env="WORDPRESS_DB_NAME=wordpress" \
  --container-mount-host-path mount-path=/var/www/html,host-path=/mnt/disks/data/data,mode=rw \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=data-wordpress,device-name=data-wordpress,mode=rw,boot=no"
