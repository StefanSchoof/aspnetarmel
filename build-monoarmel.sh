#!/bin/bash
noBuild=("3.8.0/" "3.10.0/")
GitFolder="mono-docker"
GitUrl="https://github.com/mono/docker.git"
FolderGlob="*/"
ImageName="aspnetarmel/armel-mono"
SedCommands='
s/FROM debian/FROM armel\/debian/
/.*deb http:\/\/download.mono-project.com\/repo\/debian [0-9]\+-security main.*/d
s/MAINTAINER .*/MAINTAINER <https:\/\/github.com\/StefanSchoof\/aspnetarmel>/
'

rm -rf $GitFolder
git clone $GitUrl $GitFolder
docker pull armel/debian:wheezy
cd $GitFolder
sed -i -e "$SedCommands" ${FolderGlob}Dockerfile
for version in $(ls -1d $FolderGlob)
do
	if [[ ! " ${noBuild[@]} " =~ " ${version} " ]]; then
		docker build -t ${ImageName}:${version%/} $version
		docker push ${ImageName}:${version%/}
	fi
done
