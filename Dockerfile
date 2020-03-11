FROM openjdk:8-jdk-slim

RUN apt-get update && apt-get install -y python3 python3-pip libsnappy-dev git wget zip

WORKDIR /opt/glue

RUN export MAVEN_VERSION=3.6.0 && \
    wget https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-common/apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    tar -zxf apache-maven-${MAVEN_VERSION}-bin.tar.gz && \
    mv apache-maven-${MAVEN_VERSION} maven && \
    rm apache-maven-${MAVEN_VERSION}-bin.tar.gz 

RUN export SPARK_VERSION=2.4.3 && \
    wget https://aws-glue-etl-artifacts.s3.amazonaws.com/glue-1.0/spark-${SPARK_VERSION}-bin-hadoop2.8.tgz && \
    tar -zxf spark-${SPARK_VERSION}-bin-hadoop2.8.tgz && \
    mv spark-${SPARK_VERSION}-bin-spark-${SPARK_VERSION}-bin-hadoop2.8 spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop2.8.tgz

ENV PYSPARK_PYTHON=python3
ENV SPARK_HOME=/opt/glue/spark
ENV PATH="/opt/glue/maven/bin:/opt/glue/libs/bin:${PATH}"

RUN git clone https://github.com/awslabs/aws-glue-libs.git && \
    cd aws-glue-libs && \
    git checkout 4f6ac898b7a0d2ac11b33455a3495f7627a492bc && \
    chmod +x ./bin/glue-setup.sh && \
    ./bin/glue-setup.sh && \
    rm jarsv1/netty-all-4.0.23.Final.jar && \
    cp /opt/glue/spark/jars/netty-all-4.1.17.Final.jar /opt/glue/aws-glue-libs/jarsv1

ENV SPARK_CONF_DIR=/opt/glue/aws-glue-libs/conf
ENV PYTHONPATH="${SPARK_HOME}/python:${SPARK_HOME}/python/lib/py4j-0.10.7-src.zip:/opt/glue/aws-glue-libs/PyGlue.zip:${PYTHONPATH}"

WORKDIR /root/app
