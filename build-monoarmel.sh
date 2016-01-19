#!/bin/bash
shopt -s extglob
build () {
	local "${@}"
	rm -rf ${GitFolder}
	git clone ${GitUrl} ${GitFolder}
	docker pull armel/debian:wheezy
	cd ${GitFolder}
	sed -i -e "$SedCommands" ${FolderGlob}Dockerfile
	for version in $(ls -1d ${FolderGlob})
	do
		docker build -t ${ImageName}:${version%/} ${version}
		docker run ${ImageName}:${version%/} /bin/bash -c "apt-get -q update && apt-get -s upgrade" | grep "^0 upgraded" || \
			docker build --no-cache -t ${ImageName}:${version%/} ${version}
		docker push ${ImageName}:${version%/}
	done
}

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
