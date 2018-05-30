gcloud beta compute instances create-with-container redis \
  --machine-type f1-micro \
  --boot-disk-size "10" \
  --boot-disk-type "pd-standard" \
  --container-image redis:4.0.9 \
  --container-command "redis-server" \
  --container-arg "--databases 1" \
  --container-arg "--save ''" \
  --container-arg "--maxmemory 60mb" \
  --container-arg "--maxmemory-policy allkeys-lru"
