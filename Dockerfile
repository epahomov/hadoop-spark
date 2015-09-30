FROM ubuntu:14.04

MAINTAINER Pakhomov Egor <pahomov.egor@gmail.com>

RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y --force-yes software-properties-common python-software-properties
RUN apt-add-repository -y ppa:webupd8team/java
RUN apt-get -y update
RUN /bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install oracle-java7-installer oracle-java7-set-default

ENV MAVEN_VERSION 3.3.3
RUN apt-get -y install curl
RUN curl -sSL http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz | tar xzf - -C /usr/share \
  && mv /usr/share/apache-maven-$MAVEN_VERSION /usr/share/maven \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_OPTS "-Xmx3g -XX:MaxPermSize=1g -XX:ReservedCodeCacheSize=1g"
ENV HADOOP_VERSION 2.6.0-cdh5.4.2

RUN apt-get -y install curl
RUN curl -s https://codeload.github.com/apache/spark/tar.gz/v1.5.1 | tar -xz -C /usr/local/
WORKDIR /usr/local
RUN ln -s spark-* spark
WORKDIR /usr/local/spark
RUN mvn -Pyarn -Phadoop-2.6 \
 -Dhadoop.version=$HADOOP_VERSION \
 -Phive \
 -Phive-thriftserver \ 
 -DskipTests \  
 clean \
 package

ENV SPARK_HOME /usr/local/spark

ENV SPARK_MASTER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
ENV SPARK_WORKER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"

ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_WORKER_PORT 8888
ENV SPARK_WORKER_WEBUI_PORT 8081

EXPOSE 8080 7077 8888 8081 4040 7001 7002 7003 7004 7005 7006

ENV HADOOP_CONF_DIR /usr/local/hadoop-conf

ADD spark-defaults.conf /usr/local/spark/conf/
ADD env.sh /usr/local/env.sh

ENTRYPOINT /usr/local/env.sh

