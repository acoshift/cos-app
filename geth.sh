# prepare disk
gcloud compute disks create data-eth --size=50GB --type=pd-ssd
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk data-eth
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances detach-disk prepare-disk-instance --disk data-eth
gcloud compute instances delete prepare-disk-instance

# start container
gcloud compute instances create-with-container eth \
  --machine-type n1-standard-2 \
  --container-image ethereum/client-go:v1.8.1 \
  --container-mount-host-path mount-path=/root,host-path=/mnt/disks/data,mode=rw \
  --container-arg="--cache=2000" \
  --container-arg="--fast" \
  --container-arg="--rpc" \
  --container-arg="--rpcaddr=0.0.0.0" \
  --container-arg="--ws" \
  --container-arg="--wsaddr=0.0.0.0" \
  --container-arg="--ipcdisable" \
  --container-arg="--rpcapi=eth,shh,web3,admin,debug,miner,personal,txpool" \
  --container-arg="--wsapi=eth,shh,web3,miner,personal,txpool" \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=data-eth,device-name=data-eth,mode=rw,boot=no" \
  --tags eth-node
