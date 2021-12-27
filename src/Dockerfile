FROM ubuntu:18.04

WORKDIR /tmp

RUN apt-get update && apt-get install maven -y && apt-get install git -y && apt-get install openjdk-11-jdk -y && apt-get install gnupg -y && apt-get install wget -y

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
RUN unset JAVA_HOME

ENTRYPOINT ["/tmp/entrypoint.sh"]
#CMD ["sh","-c","/bin/bash"]
