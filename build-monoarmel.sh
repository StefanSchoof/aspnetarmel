noBuild=("3.8.0/" "3.10.0/")

rm -rf mono-docker
git clone https://github.com/mono/docker.git mono-docker
cd mono-docker
sed -i "s/FROM debian/FROM armel\/debian/" */Dockerfile
sed -i "/.*deb http:\/\/download.mono-project.com\/repo\/debian [0-9]\+-security main.*/d" */Dockerfile
sed -i "s/MAINTAINER .*/MAINTAINER <https:\/\/github.com\/StefanSchoof\/aspnetarmel>/" */Dockerfile
for version in $(ls -1d */)
do
	if [[ ! " ${noBuild[@]} " =~ " ${version} " ]]; then
		docker build -t aspnetarmel/armel-mono:${version%/} $version
		docker push aspnetarmel/armel-mono:${version%/}
	fi
done

