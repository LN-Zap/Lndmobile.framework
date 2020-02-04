#!/bin/bash

cd "`dirname \"$0\"`"

export REPOROOT=$(pwd)
export GOPATH=$REPOROOT/.build
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk-bundle

set -v

go version

mkdir -p $GOPATH

go get -d -v github.com/lightninglabs/falafel
cd $GOPATH/src/github.com/lightninglabs/falafel
go install
cd $REPOROOT

go get -d -v golang.org/x/tools/go/packages
go get -d -v golang.org/x/mobile/cmd/gomobile
cd $GOPATH/src/golang.org/x/mobile/cmd/gomobile
go install
cd $REPOROOT

go get -d -v github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis
go get -d -v github.com/lightningnetwork/lnd

# install grpc
curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v3.8.0/protoc-3.8.0-linux-x86_64.zip
unzip protoc-3.8.0-linux-x86_64.zip -d protoc
rm protoc-3.8.0-linux-x86_64.zip
export PATH=$PWD/protoc/bin:$PATH

# lnd
gomobile init
cd $GOPATH/src/github.com/lightningnetwork/lnd
git checkout v0.9.0-beta

git apply $REPOROOT/patches/user_agent_name.patch
git apply $REPOROOT/patches/user_agent_version.patch

make GOPATH=$GOPATH ANDROID_BUILD_DIR=$REPOROOT android

cd $REPOROOT
zip --symlinks -r Lndmobile-android.zip Lndmobile.aar Lndmobile-sources.jar
rm Lndmobile.aar Lndmobile-sources.jar
