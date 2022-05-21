docker build --no-cache -t influxdb-sample .
docker network create project_network1
docker run --network=project_network1 --env-file ./env/env.app influxdb-sample