# prepare disk
gcloud compute disks create disk-eth-mainnet --size=50GB --type=pd-ssd
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk disk-eth-mainnet
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances detach-disk prepare-disk-instance --disk disk-eth-mainnet
gcloud compute instances delete prepare-disk-instance

# start container
gcloud compute instances create-with-container eth-mainnet \
  --machine-type n1-standard-2 \
  --container-image parity/parity:v1.8.5 \
  --container-mount-host-path mount-path=/root,host-path=/mnt/disks/data,mode=rw \
  --container-arg="--jsonrpc-interface=all" \
  --container-arg="--jsonrpc-threads=6" \
  --container-arg="--ws-interface=all" \
  --container-arg="--no-ipc" \
  --container-arg="--ui-interface=all" \
  --container-arg="--ui-hosts=all" \
  --container-arg="--chain=mainnet" \
  --container-arg="--mode=active" \
  --container-arg="--log-file=/root/parity.log" \
  --container-arg="--no-config" \
  --container-arg="--no-color" \
  --container-arg="--cache-size=5120" \
  --container-arg="--no-serve-light" \
  --container-arg="--max-peers=200" \
  --container-arg="--scale-verifiers" \
  --container-arg="--num-verifiers=12" \
  --container-arg="--jsonrpc-apis=all" \
  --metadata ^:^startup-script="mkdir -p /mnt/disks/data && mount -o discard,defaults /dev/sdb /mnt/disks/data" \
  --disk "name=disk-eth-mainnet,device-name=disk-eth-mainnet,mode=rw,boot=no" \
  --tags eth-node
