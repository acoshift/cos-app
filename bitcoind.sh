# prepare disk
gcloud compute disks create disk-bitcoind --size=250GB --type=pd-standard
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk disk-bitcoind
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container bitcoind \
  --machine-type n1-highcpu-4 \
  --container-image kylemanna/bitcoind@sha256:62afc775a839720ce608039e2ba1a5861a2d92b20a21ea24a1e3b1abda805e7c \
  --container-mount-host-path mount-path=/bitcoin,host-path=/mnt/disks/data,mode=rw \
  --container-arg="-dbcache=2000" \
  --container-arg="-rpcallowip=::/0" \
  --container-arg="-par=4" \
  --container-arg="-maxuploadtarget=200" \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=disk-bitcoind,device-name=disk-bitcoind,mode=rw,boot=no" \
  --tags allow-bitcoind
gcloud compute firewall-rules create allow-bitcoind \
  --allow tcp:8333,8332 --target-tags allow-bitcoind
