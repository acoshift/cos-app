# prepare disk
gcloud compute disks create disk-geth --size=350GB --type=pd-standard
gcloud compute instances create prepare-disk-instance --machine-type f1-micro
gcloud compute instances attach-disk prepare-disk-instance --disk disk-geth
gcloud compute ssh prepare-disk-instance -- 'sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb'
gcloud compute instances delete prepare-disk-instance

# start container
gcloud beta compute instances create-with-container geth \
  --machine-type n1-highcpu-4 \
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
  --disk "name=disk-geth,device-name=disk-geth,mode=rw,boot=no" \
  --tags allow-geth

# setup firewall
gcloud compute firewall-rules create allow-geth \
  --allow tcp:8545,8546,30303 --target-tags allow-geth
