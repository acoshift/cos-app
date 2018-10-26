# prepare disk
gcloud compute disks create data-mariadb --size=10GB --type=pd-ssd
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk data-mariadb
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances detach-disk prepare-disk-instance --disk data-mariadb
gcloud compute instances delete prepare-disk-instance

# start container
gcloud compute instances create-with-container mariadb \
  --machine-type f1-micro \
  --container-image mariadb:10.3.10 \
  --container-env="MYSQL_ROOT_PASSWORD=root" \
  --container-mount-host-path mount-path=/var/lib/mysql,host-path=/mnt/disks/data/data,mode=rw \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=data-mariadb,device-name=data-mariadb,mode=rw,boot=no"
