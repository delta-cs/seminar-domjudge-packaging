#!/bin/sh -eu

if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]
then
	echo "Usage: $0 domjudge-version"
	echo "	For example: $0 5.3.0"
	exit 1
fi

# Placeholders for grouping log lines
# (the body is a nested function declaration so it won't appear in the trace when using `set -x`)
section_start() { _() { :; }; }
section_end() { _() { :; }; }

if [ -n "${CI+x}" ]
then
	if [ -n "${GITHUB_ACTION+x}" ]
	then
		# Functions for grouping log lines on GitHub Actions
		trace_on() { set -x; }
		# trace_off is manually inlined so it won't appear in the trace
		section_start() {
			{ set +x; } 2>/dev/null # trace_off
			echo "::group::$1"
			trace_on
		}
		section_end() {
			{ set +x; } 2>/dev/null # trace_off
			echo "::endgroup::"
			trace_on
		}
		# Redirect stderr to stdout as a workaround so they won't be out-of-order; see
		# https://github.com/orgs/community/discussions/116552
		# https://web.archive.org/web/20220430214837/https://github.community/t/stdout-stderr-output-not-in-correct-order-in-logs/16335
		# (GitHub Actions displays stderr in the same style as stdout anyway, so
		# there is no harm in us merging them.)
		exec 2>&1
	fi
	set -x
fi

section_start "Variables"
VERSION="$1"
URL=https://www.domjudge.org/releases/domjudge-${VERSION}.tar.gz
URL=https://github.com/delta-cs/seminar-domjudge/archive/refs/tags/${VERSION}.tar.gz
FILE=domjudge.tar.gz
section_end

section_start "Download DOMjudge tarball"
echo "[..] Downloading DOMjudge version ${VERSION}..."
if ! wget --quiet "${URL}" -O ${FILE}
then
	echo "[!!] DOMjudge version ${VERSION} file not found on https://www.domjudge.org/releases"
	exit 1
fi
echo "[ok] DOMjudge version ${VERSION} downloaded as domjudge.tar.gz"; echo
section_end

section_start "Build domserver container"
echo "[..] Building Docker image for domserver..."
./build-domjudge.sh "deltacs/seminar-domserver:${VERSION}"
echo "[ok] Done building Docker image for domserver"
section_end

section_start "Build judgehost container (with intermediate image)"
echo "[..] Building Docker image for judgehost using intermediate build image..."
./build-judgehost.sh "deltacs/seminar-judgehost:${VERSION}"
echo "[ok] Done building Docker image for judgehost"
section_end

section_start "Build judgehost container (judging chroot)"
echo "[..] Building Docker image for judgehost chroot..."
docker build -t "deltacs/seminar-default-judgehost-chroot:${VERSION}" -f judgehost/Dockerfile.chroot .
echo "[ok] Done building Docker image for judgehost chroot"
section_end

section_start "Push instructions"
echo "All done. Image deltacs/seminar-domserver:${VERSION} and deltacs/seminar-judgehost:${VERSION} created"
echo "If you are a DOMjudge maintainer with access to the domjudge organization on Docker Hub, you can now run the following command to push them to Docker Hub:"
echo "$ docker push deltacs/seminar-domserver:${VERSION} && docker push deltacs/seminar-judgehost:${VERSION} && docker push deltacs/seminar-default-judgehost-chroot:${VERSION}"
echo "If this is the latest release, also run the following command:"
echo "$ docker tag deltacs/seminar-domserver:${VERSION} deltacs/seminar-domserver:latest && \
docker tag deltacs/seminar-judgehost:${VERSION} deltacs/seminar-judgehost:latest && \
docker tag deltacs/seminar-default-judgehost-chroot:${VERSION} deltacs/seminar-default-judgehost-chroot:latest && \
docker push deltacs/seminar-domserver:latest && docker push deltacs/seminar-judgehost:latest && docker push deltacs/seminar-default-judgehost-chroot:latest"
section_end
