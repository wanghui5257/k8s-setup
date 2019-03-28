#!/bin/bash

images="heapster-amd64:v1.4.0 heapster-influxdb-amd64:v1.3.3 heapster-grafana-amd64:v4.4.3"
for imageName in ${images} ; do
  docker pull alleyj/$imageName
  docker tag alleyj/$imageName gcr.io/google_containers/$imageName
  docker rmi alleyj/$imageName
done

