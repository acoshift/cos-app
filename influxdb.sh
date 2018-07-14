gcloud beta compute instances create-with-container influxdb \
  --machine-type g1-small \
  --boot-disk-size "10" \
  --boot-disk-type "pd-standard" \
  --container-image influxdb:1.6.0 \
  --container-mount-host-path mount-path=/var/lib/influxdb,host-path=/mnt/stateful_partition/data,mode=rw
