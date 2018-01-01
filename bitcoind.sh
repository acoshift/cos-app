# prepare disk
gcloud compute disks create disk-btc-1 --size=250GB --type=pd-ssd
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk disk-btc-1
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances detach-disk prepare-disk-instance --disk disk-btc-1
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container btc-1 \
  --machine-type n1-standard-2 \
  --container-image kylemanna/bitcoind@sha256:62afc775a839720ce608039e2ba1a5861a2d92b20a21ea24a1e3b1abda805e7c \
  --container-mount-host-path mount-path=/bitcoin,host-path=/mnt/disks/data,mode=rw \
  --container-arg="-dbcache=5500" \
  --container-arg="-rpcallowip=::/0" \
  --container-arg="-par=4" \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=disk-btc-1,device-name=disk-btc-1,mode=rw,boot=no" \
  --tags btc-node
