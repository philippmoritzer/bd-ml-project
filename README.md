# Keywords

# Introduction

# Basics
## NoSQL basics

## NoSQL vs relational Databases

## TimeSeries databases

## InfluxDB basics

### flux query language

## influxdb vs timescale vs prometheus

# Tutorial

## Goals
The purpose of this project is to process a large amount of time series data. The data is stored using a NoSQL approach with InfluxDB. A Grafana Dashboard is constructed to visualize the data, and appropriate visualisation tools are employed. The data will be parsed using
Python and processed to InfluxDB using functional programming in combination with the python
client library provided by InfluxDB.

## The data - Movebank: Animal tracking

## Prerequisites

- Python 3.10 https://www.python.org/downloads/
- Docker (20+, Version 20.10.13 is used for this project) https://docs.docker.com/get-docker/
- docker-compose installed (1.20+, Version 1.29.2 is used for this project) https://docs.docker.com/compose/install/

It is advised to use the most recent versions.
The following commands can be used to determine whether the requirements have been met:

```bash
$ python3 --verison
# Output: Python 3.10.*
$ docker -version
# Output: Docker version 20.10.13, build a224086
$ docker-comopse --version
# Output: docker-compose version 1.29.2, build 5becea4c
```

## Spinning up the composition
###
### docker-compose
There is no need to install InfluxDB or Grafana locally to quickly spin up our environment. Although it is possible to follow along using locally installed instances, docker-compose makes it easier to spin up the services. If no project root has yet been created, create a new folder for the project and add the following ``docker-compose.yml`` file:
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
      - ./data/influxdb:/var/lib/influxdb2
    networks:
      - network1

  grafana:
    image: grafana/grafana:7.5.16
    container_name: grafana
    ports:
      - "3000:3000"
    user: "0"
    links:
      - influxdb
    volumes:
      - ./data/grafana:/var/lib/grafana
    networks:
      - network1

networks:
  network1:
```

Volumes are used by both InfluxDB and grafana. The next step is to make sure that a directory called data is created in the project root directory, which contains two empty subdirectories called grafana/ and influxdb/. These directories will be filled to persist data when using these applications.

```
- <project-root> 
  - data/
    - grafana/
    - influxdb/
  - env/
    - env.app
    - env.influxdb
  docker-compose.yml
```

> Note for Unix-Users: If the Grafana-Container fails to start due to permission errors, the permission of the ./data/grafana Folder should be changed to 472 and made sure it is owned by the account using it.

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
