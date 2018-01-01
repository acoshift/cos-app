# prepare disk
gcloud compute disks create disk-eth-1 --size=100GB --type=pd-ssd
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk disk-eth-1
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container eth-1 \
  --machine-type n1-standard-1 \
  --container-image ethereum/client-go:v1.7.3 \
  --container-mount-host-path mount-path=/root,host-path=/mnt/disks/data,mode=rw \
  --container-arg="--cache=2000" \
  --container-arg="--fast" \
  --container-arg="--rpc" \
  --container-arg="--rpcaddr=0.0.0.0" \
  --container-arg="--ws" \
  --container-arg="--wsaddr=0.0.0.0" \
  --container-arg="--ipcdisable" \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=disk-eth-1,device-name=disk-eth-1,mode=rw,boot=no" \
  --tags eth-node
