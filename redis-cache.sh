gcloud compute instances create-with-container redis \
  --custom-cpu=1 \
  --custom-memory=1 \
  --boot-disk-size "10" \
  --boot-disk-type "pd-standard" \
  --container-image redis:4.0.11 \
  --container-command "redis-server" \
  --container-arg "--databases 1" \
  --container-arg "--save ''" \
  --container-arg "--maxmemory 500mb" \
  --container-arg "--maxmemory-policy allkeys-lru" \
  --metadata ^:^startup-script="echo never > /sys/kernel/mm/transparent_hugepage/enabled && sysctl -w net.core.somaxconn=65535"
