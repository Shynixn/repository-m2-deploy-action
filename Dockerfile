FROM ubuntu:18.04

WORKDIR /tmp

RUN apt-get update
RUN apt-get install maven -y
RUN apt-get install git -y
RUN apt-get install openjdk-11-jdk -y

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
RUN export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

ENTRYPOINT ["./entrypoint.sh"]
