# prepare disk
gcloud compute disks create data-influxdb --size=10GB --type=pd-standard
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk data-influxdb
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances detach-disk prepare-disk-instance --disk data-influxdb
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container influxdb \
  --machine-type n1-standard-1 \
  --container-image influxdb:1.6.0 \
  --container-mount-host-path mount-path=/var/lib/influxdb,host-path=/mnt/disks/data/data,mode=rw \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=data-influxdb,device-name=data-influxdb,mode=rw,boot=no"
