# Building and visualizing a NoSQL time series data store using InfluxDB, Grafana and Python
- [Building and visualizing a NoSQL time series data store using InfluxDB, Grafana and Python](#building-and-visualizing-a-nosql-time-series-data-store-using-influxdb-grafana-and-python)
- [Introduction](#introduction)
- [Basics](#basics)
  - [NoSQL basics](#nosql-basics)
  - [NoSQL vs relational Databases](#nosql-vs-relational-databases)
  - [TimeSeries databases](#timeseries-databases)
  - [InfluxDB basics](#influxdb-basics)
    - [flux query language](#flux-query-language)
  - [influxdb vs timescale vs prometheus](#influxdb-vs-timescale-vs-prometheus)
- [Tutorial](#tutorial)
  - [Goals](#goals)
  - [The data - Movebank: Animal tracking](#the-data---movebank-animal-tracking)
  - [Prerequisites](#prerequisites)
  - [Spinning up the composition](#spinning-up-the-composition)
    - [docker-compose](#docker-compose)
  - [Setting up InfluxDB](#setting-up-influxdb)
  - [Writing the client application](#writing-the-client-application)
    - [Setting up the environment](#setting-up-the-environment)
    - [Setting up the application](#setting-up-the-application)
  - [Setting up Grafana](#setting-up-grafana)
  - [](#)
  - [Python](#python)
  - [Grafana](#grafana)
  - [Run sample project](#run-sample-project)
- [Summary](#summary)

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
Python and processed to InfluxDB using functional programming in combination with the Python
client library provided by InfluxDB.

## The data - Movebank: Animal tracking

The data processed in this example is 

## Prerequisites

- Python 3.10 (with pip3) https://www.python.org/downloads/
- Docker (20+, Version 20.10.13 is used for this project) https://docs.docker.com/get-docker/
- docker-compose installed (1.20+, Version 1.29.2 is used for this project) https://docs.docker.com/compose/install/

It is advised to use the most recent versions.
The following commands can be used to determine whether the requirements have been met:

```bash
$ python3 --version
# Output: Python 3.10.*
$ docker -version
# Output: Docker version 20.10.13, build a224086
$ docker-comopse --version
# Output: docker-compose version 1.29.2, build 5becea4c
```

## Spinning up the composition
###
### docker-compose
There is no need to install InfluxDB or Grafana locally to quickly spin up the environment. Although it is possible to follow along using locally installed instances, docker-compose makes it easier to spin up the services. If no project root has yet been created, create a new folder for the project and add the following ``docker-compose.yml`` file:
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

Volumes are used by both InfluxDB and Grafana. The next step is to make sure that a directory called ``data/`` is created in the project root directory, which contains two empty subdirectories called ``grafana/`` and ``influxdb/``. These directories will be filled to persist data when using these applications. Later in the tutorial, they will be filled in. This is how the project should be structured now:

```
- <project-root> 
  - data/
    - grafana/
    - influxdb/
  docker-compose.yml
```

Also a network is added in the ``docker-compose.yml`` file so our Python application is able to communicate with the services on the same network later on when using Docker.
Docker-compose is used to spin up a local instance of InfluxDB and Grafana. To start both services, enter 

```bash
docker-compose up
```

> Note for Unix-Users: If the Grafana-Container fails to start due to permission errors, the permission of the ./data/grafana Folder should be changed to 472 and made sure it is owned by the account using it.

The InfluxDB exposed the Port 8086 for the web interface and should now be reachable locally on ``http://localhost:8086/``:

InfluxDB on localhost:8086
![alt text](./docs/images/docker-compose-setup/influx-welcome.png "Influx running on localhost:8086")

While Grafana uses Port 3000 for its web interface and should be reachable by typint ``http://localhost:3000`` in a browser:

![alt text](./docs/images/docker-compose-setup/grafana-welcome.png "Grafana running on localhost:3000") *Grafana on localhost:3000*



## Setting up InfluxDB

To access the InfluxDB web interface, go to ``localhost:8086``. Press 'Get Started' to begin the setup procedure. The setup then asks for a login, password, organization name, and an initial bucket name in the next stage. The password for ``root`` is ``password``, and the initial organization name is my tag ``pmoritzer``. The bucket name must be set initially, but the bucket is not needed because our data processing unit python application will create a bucket dynamically in the future. The information should be saved because it will be required to log in to the web interface later on and the organization name will serve as an identifier in the client application.

![alt text](./docs/images/influxdb-setup/initial-account.png)*First setup step for InfluxDB*

Because we want to inject data manually, simply select "Configure later" in the following step.
The final step in setting up InfluxDB is to obtain the necessary API token.
To do so, select the Data tab in the left sidebar, followed by the "API Tokens" tab in the tab view on top. A window will appear when you click on root's Token including the API Token. To access the InfluxDB from an external application, the token should be saved somewhere. Because security is not an issue in this proof of concept, we can use the root token; however, in a production environment, separate users with access rights should be set up.

![alt text](./docs/images/influxdb-setup/api-token-1.png)*InfluxDB API-Token 1/2*

![alt text](./docs/images/influxdb-setup/api-token-2.png)*InfluxDB API-Token 2/2*

## Writing the client application

### Setting up the environment
First, environment variables that will be required to connect to the local instance of InfluxDB will be set. Using an environment file, a folder called ``<project-root>/env/`` will be created within the project root directory. A file called ``env.app`` will be created that looks as follows:

```properties
INFLUX_URL=http://influxdb:8086
INFLUX_TOKEN=<root-api-token>
INFLUX_ORG=<org-name>
```

Replace the ``INFLUX_TOKEN`` property to equal the generated API-Token from the setup and the ``INFLUX_ORG`` properties with the organization name set. The data processing client application is able to connect to the database by loading these definded properties.

### Setting up the application

Create a file called ``main.py``in the project's root directory that will serve as an entrypoint for the client application. First we will do a simple output to check whether our application works.

```python
print ("Hello World")
```
*main.py*
```bash
$ python3 main.py
# Output: Hello World
```

For the dependencies a ``requirements.txt``file is created in the project's root directory with following content to install the python client library for InfluxDB using pip. To make sure they are locally available, run the follwing command:

```bash
$ pip3 install -r requirements.txt

```

Next, we're going to dockerize the application. To do so, a Dockerfile will be created. Docker ensures that the application can run with the dependencies defined regardless of the system's environment.


```properties
influxdb-client == 1.29.0
```

```Dockerfile
# syntax=docker/dockerfile:1
FROM python:3.10.4-slim-bullseye

WORKDIR /app

COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

COPY . .

CMD ["python3","-u","./main.py"]
```


Furthermore create a folder ``app/`` including a file ``connect_to_influx.py``.

## Setting up Grafana

## 

python3 -m pip install influxdb

## Python
## Grafana



## Run sample project

# Summary
