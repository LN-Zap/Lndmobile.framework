#!/bin/bash

cd "`dirname \"$0\"`"

export REPOROOT=$(pwd)
export GOPATH=$REPOROOT/.build
export GOBIN=$GOPATH/bin
export PATH=$GOBIN:$PATH

set -v

go version

mkdir -p $GOPATH

go get -d -v github.com/halseth/falafel
cd $GOPATH/src/github.com/halseth/falafel
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
curl -LO https://github.com/google/protobuf/releases/download/v3.4.0/protoc-3.4.0-osx-x86_64.zip
unzip protoc-3.4.0-osx-x86_64.zip -d protoc
export PATH=$PWD/protoc/bin:$PATH

# install protoc-gen-swift and protoc-gen-swiftgrpc
git clone https://github.com/grpc/grpc-swift.git
cd grpc-swift
make plugin
cd $REPOROOT
export PATH=$PWD/grpc-swift:$PATH

# install protoc-gen-zap
git clone https://github.com/LN-Zap/protoc-gen-zap.git
cd protoc-gen-zap
make
cd $REPOROOT
export PATH=$PWD/protoc-gen-zap:$PATH

# lnd
gomobile init
cd $GOPATH/src/github.com/lightningnetwork/lnd
git checkout v0.8.0-beta

git apply $REPOROOT/patches/user_agent_name.patch
git apply $REPOROOT/patches/user_agent_version.patch

make GOPATH=$GOPATH IOS_BUILD_DIR=$REPOROOT ios

cd $REPOROOT
zip --symlinks -r Lndmobile.framework.zip Lndmobile.framework

# Generate the protos.
mkdir generated
OUT=generated

protoc -I/usr/local/include -I.\
       -I$GOPATH/src/github.com/lightningnetwork/lnd/lnrpc \
       -I$GOPATH/src/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
       --swift_out=$OUT \
       --zap_out=$OUT \
       --swiftgrpc_out=Sync=false,Server=false:$OUT \
       $GOPATH/src/github.com/lightningnetwork/lnd/lnrpc/rpc.proto
zip -j -r Lndmobile-swift-generated.zip generated
