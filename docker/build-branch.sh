#!/bin/sh -eu

if [ -n "${CI+}" ]
then
	set -x
	export PS4='(${0}:${LINENO}): - [$?] $ '
fi

if [ "$#" -ne 1 ]
then
	echo "Usage: $0 domjudge-version"
	echo "	For example: $0 5.3.0"
	exit 1
fi

VERSION="$1"

#URL=https://www.domjudge.org/releases/domjudge-${VERSION}.tar.gz
#URL=https://github.com/delta-cs/seminar-domjudge/archive/refs/tags/${VERSION}.tar.gz
URL=https://api.github.com/repos/delta-cs/seminar-domjudge/tarball/${VERSION}
FILE=domjudge.tar.gz

echo "[..] Downloading DOMjudge version ${VERSION}..."

if ! wget --quiet "${URL}" -O ${FILE}
then
	echo "[!!] DOMjudge version ${VERSION} file not found on https://www.domjudge.org/releases"
	exit 1
fi

echo "[ok] DOMjudge version ${VERSION} downloaded as domjudge.tar.gz"; echo

echo "[..] Building Docker image for domserver..."
#./build-domjudge.sh "domjudge/domserver:${VERSION}"
./build-domjudge.sh "deltacs/seminar-domserver:${VERSION}"
echo "[ok] Done building Docker image for domserver"

echo "[..] Building Docker image for judgehost using intermediate build image..."
#./build-judgehost.sh "domjudge/judgehost:${VERSION}"
./build-judgehost.sh "deltacs/seminar-judgehost:${VERSION}"
echo "[ok] Done building Docker image for judgehost"

echo "[..] Building Docker image for judgehost chroot..."
#docker build -t "domjudge/default-judgehost-chroot:${VERSION}" -f judgehost/Dockerfile.chroot .
docker build -t "deltacs/seminar-default-judgehost-chroot:${VERSION}" -f judgehost/Dockerfile.chroot .
echo "[ok] Done building Docker image for judgehost chroot"

#echo "All done. Image domjudge/domserver:${VERSION} and domjudge/judgehost:${VERSION} created"
#echo "If you are a DOMjudge maintainer with access to the domjudge organization on Docker Hub, you can now run the following command to push them to Docker Hub:"
#echo "$ docker push domjudge/domserver:${VERSION} && docker push domjudge/judgehost:${VERSION} && docker push domjudge/default-judgehost-chroot:${VERSION}"
#echo "If this is the latest release, also run the following command:"
#echo "$ docker tag domjudge/domserver:${VERSION} domjudge/domserver:latest && \
#docker tag domjudge/judgehost:${VERSION} domjudge/judgehost:latest && \
#docker tag domjudge/default-judgehost-chroot:${VERSION} domjudge/default-judgehost-chroot:latest && \
#docker push domjudge/domserver:latest && docker push domjudge/judgehost:latest && docker push domjudge/default-judgehost-chroot:latest"

echo "All done. Image deltacs/seminar-domserver:${VERSION} and deltacs/seminar-judgehost:${VERSION} created"
echo "If you are a DOMjudge maintainer with access to the domjudge organization on Docker Hub, you can now run the following command to push them to Docker Hub:"
echo "$ docker push deltacs/seminar-domserver:${VERSION} && docker push deltacs/seminar-judgehost:${VERSION} && docker push deltacs/seminar-default-judgehost-chroot:${VERSION}"
