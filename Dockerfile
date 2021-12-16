FROM ubuntu:18.04

WORKDIR /tmp

RUN apt-get update
RUN apt-get install maven -y
RUN apt-get install git -y

COPY entrypoint.sh entrypoint.sh

ENTRYPOINT ["/tmp/entrypoint.sh"]
#CMD ["sh","-c","/bin/bash"]
