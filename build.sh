#!/bin/bash

cd "`dirname \"$0\"`"

export REPOROOT=$(pwd)
export GOPATH=$REPOROOT/.build
export PATH=$GOPATH/bin:$PATH

set -v

mkdir -p $GOPATH

go get -d -v github.com/halseth/falafel
go get -d -v golang.org/x/tools/go/packages
go get -d -v golang.org/x/mobile/cmd/gomobile
cd $GOPATH/src/golang.org/x/mobile/cmd/gomobile
go install

go get -d -v github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis
go get -d -v github.com/lightningnetwork/lnd

gomobile init
cd $GOPATH/src/github.com/lightningnetwork/lnd
git checkout v0.8.0-beta-rc1

git apply $REPOROOT/patches/user_agent_name.patch
git apply $REPOROOT/patches/user_agent_version.patch

make tags="experimental" IOS_BUILD_DIR=$REPOROOT ios

cd $REPOROOT
zip -r Lndmobile.framework.zip Lndmobile.framework

