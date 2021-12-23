#!/bin/sh -l

# Parameters
parameterMainJar=$1
groupId=$2
artifactId=$3
version=$4
githubAccessToken=$5
githubUserName=$6
githubRepository=$7
folderPath=$8
signingKey=$9
signingPassword=$10
kotlinDocsJar="$11"
sourceDirs=$12
sourceJar="$13"

# Rename jar artifact to maven format
mainJarFile="$groupId-$artifactId-$version.jar"
mv $parameterMainJar $mainJarFile

# Generate full folder path
fullFolderPath=master/docs/repository/$folderPath

# Setup the repository
git config --global user.email "repository-m2-deployment-agent@email.com" && git config --global user.name "Repository M2 Deployment Agent"
git clone "https://$githubUserName:$githubAccessToken@github.com/$githubUserName/$githubRepository.git" master
mkdir -p $fullFolderPath

# Install the files into the repository
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
mvn install:install-file "-DgroupId=$groupId" "-DartifactId=$artifactId" "-Dversion=$version" "-Dfile=$mainJarFile" -Dpackaging=jar -DgeneratePom=true "-DlocalRepositoryPath=$fullFolderPath" -DcreateChecksum=true

# Optional JavaDocs
if [ "$kotlinDocsJar" = "true" ]; then
  wget https://repo1.maven.org/maven2/org/jetbrains/dokka/dokka-cli/1.5.31/dokka-cli-1.5.31.jar -O /app/dokka-cli.jar
  wget https://repo1.maven.org/maven2/org/jetbrains/dokka/dokka-base/1.5.31/dokka-base-1.5.31.jar -O dokka-base.jar
  wget https://repo1.maven.org/maven2/org/jetbrains/dokka/dokka-analysis/1.5.31/dokka-analysis-1.5.31.jar -O dokka-analysis.jar
  wget https://repo1.maven.org/maven2/org/jetbrains/dokka/kotlin-analysis-compiler/1.5.31/kotlin-analysis-compiler-1.5.31.jar -O kotlin-analysis-compiler.jar
  wget https://repo1.maven.org/maven2/org/jetbrains/dokka/kotlin-analysis-intellij/1.5.31/kotlin-analysis-intellij-1.5.31.jar -O kotlin-analysis-intellij.jar
  wget https://repo1.maven.org/maven2/org/jetbrains/kotlinx/kotlinx-html-jvm/0.7.3/kotlinx-html-jvm-0.7.3.jar -O kotlinx-html-jvm.jar
  mkdir kotlinDocs
  requiredDokkaPlugins="dokka-base.jar;dokka-analysis.jar;kotlin-analysis-compiler.jar;kotlin-analysis-intellij.jar;kotlinx-html-jvm.jar"
  ls
  chmod +x dokka-cli.jar
  java -jar dokka-cli.jar -moduleName "$artifactId" -pluginsClasspath $requiredDokkaPlugins -sourceSet "-src $sourceDirs" -outputDir "kotlinDocs"
  javaDocJarFile="$artifactId-$version-javadoc.jar"
  jar cvf "$javaDocJarFile" -C kotlinDocs .
  mvn install:install-file "-DgroupId=$groupId" "-DartifactId=$artifactId" "-Dversion=$version" "-Dfile=$javaDocJarFile" -Dpackaging=jar -DgeneratePom=true "-DlocalRepositoryPath=$fullFolderPath" -DcreateChecksum=true -Dclassifier=javadoc
fi

# Optional Sources
if [ "$sourceJar" = "true" ]; then
  sourcesJarFile="$artifactId-$version-sources.jar"
  sourceCommand="jar cvf $sourcesJarFile"
  IN=$sourceDirs
  while [ "$IN" != "$iter" ] ;do
      # extract the substring from start of string up to delimiter.
      iter=${IN%%;*}
      # delete this first "element" AND next separator, from $IN.
      IN="${IN#$iter;}"
      # Print (or doing anything with) the first "element".
      sourceCommand="$sourceCommand -C $iter ."
  done
  eval  $"( "${sourceCommand}" )"
  mvn install:install-file "-DgroupId=$groupId" "-DartifactId=$artifactId" "-Dversion=$version" "-Dfile=$sourcesJarFile" -Dpackaging=jar -DgeneratePom=true "-DlocalRepositoryPath=$fullFolderPath" -DcreateChecksum=true -Dclassifier=sources
fi

# Optional Signing
if [ -n "$signingKey" ]; then
  echo $signingKey > raw.txt
  base64 --decode raw.txt > secret.asc
  installFolder=$fullFolderPath/$(echo "$groupId" | sed -e "s~\.~/~g")/$artifactId/$version
  gpg --batch --import --armor secret.asc
  gpg --list-keys
  find $installFolder -maxdepth 100 -not -name "*.asc" -type f -exec sh -c 'echo $1 | gpg -ab --batch --yes --passphrase-fd 0 --pinentry-mode loopback $0 && echo Signed $0.' {} $signingPassword ';'
fi

# Push the changes to Github
cd master
git add --all
git commit --message "Deployment of artifact '$mainJarFile'."
#git push --quiet "https://$githubUserName:$githubAccessToken@github.com/$githubUserName/$githubRepository.git" HEAD:main
echo "Deployed artifact '$mainJarFile'."
