#!/bin/bash

alpinePackage="openjdk8-jre"
alpineVersion='3.3'
alpineMirror="http://dl-cdn.alpinelinux.org/alpine/v${alpineVersion}/community/x86_64"
curl -fsSL'#' "$alpineMirror/APKINDEX.tar.gz" | tar -zxv APKINDEX

alpinePackageVersion="$(awk -F: '$1 == "P" { pkg = $2 } pkg == "'"$alpinePackage"'" && $1 == "V" { print $2 }' APKINDEX)"
alpineFullVersion="${alpinePackageVersion/./u}"
alpineFullVersion="${alpineFullVersion%%.*}"

sed -i -r "s/(ENV JAVA_VERSION) .*/\1 $alpineFullVersion/"  Dockerfile
sed -i -r "s/(ENV JAVA_ALPINE_VERSION) .*/\1 $alpinePackageVersion/" Dockerfile

rm APKINDEX
