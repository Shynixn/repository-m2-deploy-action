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

# Optional Signing
if [ -n "$signingKey" ]; then
  $signingKey=$(echo "$signingKey" | base64 --decode)
  echo $signingKey > secret.asc
  installFolder=$fullFolderPath/$(echo "$groupId" | sed -e "s~\.~/~g")/$artifactId/$version
  echo $installFolder
  gpg --batch --import --armor secret.asc
  gpg --list-keys
  find $installFolder -maxdepth 100 -not -name "*.asc" -type f -exec sh -c 'echo $1 | gpg -ab --batch --yes --passphrase-fd 0 --pinentry-mode loopback $0 && echo Signed $0.' {} $signingPassword ';'
fi

# Push the changes to Github
cd master
git add --all
git commit --message "Deployment of artifact '$mainJarFile'."
git push --quiet "https://$githubUserName:$githubAccessToken@github.com/$githubUserName/$githubRepository.git" HEAD:main
echo "Deployed artifact '$mainJarFile'."
