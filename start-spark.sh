#!/bin/bash
docker pull epahomov/hadoop-spark
docker run -i -t -P -v ~/:/usr/local/homedir /etc/hadoop/:/usr/local/hadoop /etc/hive/:/usr/local/hive  epahomov/docker-spark
