#!/bin/sh -l

# Parameters
parameterMainJar=$1
groupId=$2
artifactId=$3
version=$4
githubAccessToken=$5
githubUserName=$6
githubRepository=$7
folderPath=$7

# Rename jar artifact to maven format
mainJarFile="$groupId-$artifactId-$version.jar"
mv $parameterMainJar $mainJarFile

# Generate full folder path
fullFolderPath=master/docs/repository/$folderPath

# Setup the repository
git config --global user.email "repository-m2-deployment-agent@email.com" && git config --global user.name "Repository M2 Deployment Agent"
git clone https://$githubUserName:$githubAccessToken@github.com/$githubUserName/$githubRepository.git master
mkdir -p $fullFolderPath

# Install the files into the repository
mvn install:install-file "-DgroupId=$groupId" "-DartifactId=$artifactId" "-Dversion=$version" "-Dfile=$mainJarFile" -Dpackaging=jar -DgeneratePom=true "-DlocalRepositoryPath=$fullFolderPath" -DcreateChecksum=true

# Push the changes to Github
cd master
git add --all
git commit --message "Deployment of artifact '$mainJarFile'."
git push --quiet https://$githubUserName:$githubAccessToken@github.com/$githubUserName/$githubRepository.git HEAD:main
echo "Deployed artifact '$mainJarFile'."
