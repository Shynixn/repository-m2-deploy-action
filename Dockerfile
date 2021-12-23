FROM ubuntu:18.04

WORKDIR /tmp

RUN apt-get update
RUN apt-get install maven -y
RUN apt-get install git -y
RUN apt-get install openjdk-11-jdk -y
RUN apt-get install gnupg -y

RUN apt-get install wget -y
RUN wget https://repo1.maven.org/maven2/org/jetbrains/dokka/dokka-cli/1.5.31/dokka-cli-1.5.31.jar -O dokka-cli.jar
RUN wget https://repo1.maven.org/maven2/org/jetbrains/dokka/dokka-base/1.5.31/dokka-base-1.5.31.jar -O dokka-base.jar
RUN wget https://repo1.maven.org/maven2/org/jetbrains/dokka/dokka-analysis/1.5.31/dokka-analysis-1.5.31.jar -O dokka-analysis.jar
RUN wget https://repo1.maven.org/maven2/org/jetbrains/dokka/kotlin-analysis-compiler/1.5.31/kotlin-analysis-compiler-1.5.31.jar -O kotlin-analysis-compiler.jar
RUN wget https://repo1.maven.org/maven2/org/jetbrains/dokka/kotlin-analysis-intellij/1.5.31/kotlin-analysis-intellij-1.5.31.jar -O kotlin-analysis-intellij.jar
RUN wget https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-html-jvm/0.7.3/kotlinx-html-jvm-0.7.3.jar -O kotlinx-html-jvm.jar
RUN chmod +x dokka-cli.jar
RUN ls

COPY entrypoint.sh entrypoint.sh
RUN chmod +x entrypoint.sh
RUN unset JAVA_HOME

ENTRYPOINT ["./entrypoint.sh"]
#CMD ["sh","-c","/bin/bash"]
