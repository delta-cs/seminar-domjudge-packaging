#!/bin/bash

set -euo pipefail

# Usage: https://github.com/DOMjudge/domjudge/blob/main/misc-tools/dj_make_chroot.in#L58-L87
/opt/domjudge/judgehost/bin/dj_make_chroot

/opt/domjudge/judgehost/bin/dj_run_chroot "apt update && apt install mono-mcs mono-devel"
/opt/domjudge/judgehost/bin/dj_run_chroot "apt update && apt install nodejs"
/opt/domjudge/judgehost/bin/dj_run_chroot "\
  apt update \
  && apt install wget \
  && wget -O /tmp/dotnet-install.sh https://dot.net/v1/dotnet-install.sh \
  && chmod +x /tmp/dotnet-install.sh \
  && /tmp/dotnet-install.sh --channel 8.0 --install-dir /usr/lib/dotnet-8.0 \
  && ln -s /usr/lib/dotnet-8.0/dotnet /usr/bin/dotnet-8.0 \
  && ln -s /usr/bin/dotnet-8.0 /usr/bin/dotnet \
  && dotnet --info --list-sdks \
  && rm /tmp/dotnet-install.sh \
  && apt remove wget \
"
/opt/domjudge/judgehost/bin/dj_run_chroot "
  apt update \
  && apt install rustc \
  && rustc -V \
"
/opt/domjudge/judgehost/bin/dj_run_chroot "
  apt update \
  && apt install wget unzip \
  && wget -O /tmp/kotlin-compiler.zip https://github.com/JetBrains/kotlin/releases/download/v1.9.23/kotlin-compiler-1.9.23.zip \
  && unzip /tmp/kotlin-compiler.zip -d /usr/lib/kotlin \
  && ln -s /usr/lib/kotlin/kotlinc/bin/kotlinc /usr/bin/kotlinc \
  && ln -s /usr/lib/kotlin/kotlinc/bin/kotlin /usr/bin/kotlin \
  && kotlinc -version \
  && kotlin -version \
  && rm /tmp/kotlin-compiler.zip \
  && apt remove wget unzip \
"

cd /
echo "[..] Compressing chroot"
tar -czpf /chroot.tar.gz --exclude=/chroot/tmp --exclude=/chroot/proc --exclude=/chroot/sys --exclude=/chroot/mnt --exclude=/chroot/media --exclude=/chroot/dev --one-file-system /chroot
echo "[..] Compressing judge"
tar -czpf /judgehost.tar.gz /opt/domjudge/judgehost
