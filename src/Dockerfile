FROM ubuntu:18.04

WORKDIR /tmp

RUN apt-get update
RUN apt-get install maven -y
RUN apt-get install git -y
RUN apt-get install openjdk-11-jdk -y
RUN apt-get install gnupg -y
RUN apt-get install wget -y

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
RUN unset JAVA_HOME

ENTRYPOINT ["./entrypoint.sh"]
#CMD ["sh","-c","/bin/bash"]
