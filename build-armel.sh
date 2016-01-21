#!/bin/bash
shopt -s extglob
build () {
	local "${@}"
	rm -rf ${GitFolder}
	git clone ${GitUrl} ${GitFolder}
	cd ${GitFolder}
	sed -i -e "$SedCommands" ${FolderGlob}Dockerfile
	for version in $(ls -1d ${FolderGlob})
	do
		docker build -t ${ImageName}:${version%/} ${version}
		#docker run ${ImageName}:${version%/} /bin/bash -c "apt-get -q update && apt-get -s upgrade" | grep "^0 upgraded" || \
		#	docker build --no-cache -t ${ImageName}:${version%/} ${version}
		docker push ${ImageName}:${version%/}
	done
}

docker pull armel/debian:wheezy
build \
	GitFolder="mono-docker" \
	GitUrl="https://github.com/mono/docker.git" \
	FolderGlob="!(3.8.0|3.10.0)/" \
	ImageName="aspnetarmel/armel-mono" \
	SedCommands='
s/FROM debian/FROM armel\/debian/
/.*deb http:\/\/download.mono-project.com\/repo\/debian [0-9]\+-security main.*/d
s/MAINTAINER .*/MAINTAINER <https:\/\/github.com\/StefanSchoof\/aspnetarmel>/
'

build \
	GitFolder="aspnet-docker" \
	GitUrl="https://github.com/aspnet/aspnet-docker.git" \
	FolderGlob="!(*-coreclr)/" \
	ImageName="aspnetarmel/armel-aspnet" \
	SedCommands='
s/FROM mono/FROM aspnetarmel\/armel-mono/
s/MAINTAINER .*/MAINTAINER <https:\/\/github.com\/StefanSchoof\/aspnetarmel>/
'
