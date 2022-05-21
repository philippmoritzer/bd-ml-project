# Keywords

# Introduction

# Basics
## NoSQL basics

## NoSQL vs relational Databases

## TimeSeries databases

## InfluxDB basics

## influxdb vs timescale vs prometheus

# Tutorial

## Goals

## Prerequisites

- Python 3.10 https://www.python.org/downloads/
- Docker installed
- docker-compose installed

## Spinning up the composition
###
### docker-compose
To spin up our environment easily, there is no need to install InfluxDB or Grafana locally. Although you can do it
it is easier to spin up the services using docker-compose. For this purpose a docker-compose.yml File will be created in the directory root.

```yaml
version: "3.9"

services:
  influxdb:
    image: influxdb:2.2.0-alpine
    container_name: influxdb
    ports:
      - "8083:8083"
      - "8086:8086"
      - "8090:8090"
      - "2003:2003"
    env_file:
      - './env/env.influxdb'
    volumes:
      # Data persistency
      # sudo mkdir -p /srv/docker/influxdb/data
      - ./data/influxdb:/var/lib/influxdb2
    networks:
      - network1

  grafana:
    image: grafana/grafana:7.5.16
    container_name: grafana
    ports:
      - "3000:3000"
    env_file:
      - './env/env.grafana'
    user: "0"
    links:
      - influxdb
    volumes:
      # Data persistency
      # sudo mkdir -p /srv/docker/grafana/data; chown 472:472 /srv/docker/grafana/data
      - ./data/grafana:/var/lib/grafana
    networks:
      - network1

networks:
  network1:
```

Docker-compose is used to spin up a local instance of InfluxDB and Grafana. To start both services, enter 

```bash
docker-compose up
```

TODO: hier noch etwas über was passiert auf welchem port und welche environment variablen geladen werden aus den env files

Grafana on localhost:3000
![alt text](./docs/images/docker-compose-setup/grafana-welcome.png "Grafana running on localhost:3000")

InfluxDB on localhost:8086
![alt text](./docs/images/docker-compose-setup/influx-welcome.png "Influx running on localhost:8086")
### environment
### data


## Setting up InfluxDB

Dockerfile eklären hier

## Setting up Telegraf

## Setting up Grafana

## Docker

python3 -m pip install influxdb

## Python
## Grafana



## Run sample project

# Summary
