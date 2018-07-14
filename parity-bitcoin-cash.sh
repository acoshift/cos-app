# prepare disk
gcloud compute disks create disk-btc-cash --size=350GB --type=pd-ssd
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk disk-btc-cash
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances detach-disk prepare-disk-instance --disk disk-btc-cash
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container btc-cash \
  --machine-type n1-standard-2 \
  --container-image parity/pbtc-ubuntu@sha256:ea11237167fcc4d5d96e35cf2f8d7d5e5da68d50e282ed21f57978bc6b5605ab \
  --container-mount-host-path mount-path=/root,host-path=/mnt/disks/data,mode=rw \
  --container-arg="--bitcoin-cash" \
  --container-arg="--jsonrpc-interface=0.0.0.0" \
  --container-arg="--jsonrpc-hosts=*" \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=disk-btc-cash,device-name=disk-btc-cash,mode=rw,boot=no" \
  --tags btc-node
