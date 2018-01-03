#!/usr/bin/env bash

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd )

source "$DIR/../konan.sh"

$DIR/downloadTorch.sh

TH_TARGET_DIRECTORY="$HOME/.konan/third-party/torch"

if [ x$TARGET == x ]; then
case "$OSTYPE" in
  darwin*)  TARGET=macbook; TF_TARGET=darwin ;;
  linux*)   TARGET=linux; TF_TARGET=linux ;;
  *)        echo "unknown: $OSTYPE" && exit 1;;
esac
fi

CFLAGS_macbook="-I${TH_TARGET_DIRECTORY}/include"
CFLAGS_linux="-I${TH_TARGET_DIRECTORY}/include"

var=CFLAGS_${TARGET}
CFLAGS=${!var}
var=LINKER_ARGS_${TARGET}
LINKER_ARGS=${!var}
var=COMPILER_ARGS_${TARGET}
COMPILER_ARGS=${!var} # add -opt for an optimized build.

mkdir -p $DIR/build/c_interop/
mkdir -p $DIR/build/bin/

cinterop -def $DIR/src/main/c_interop/torch.def -compilerOpts "$CFLAGS" -target $TARGET \
     -o $DIR/build/c_interop/TH || exit 1

konanc $COMPILER_ARGS -target $TARGET $DIR/src/main/kotlin/HelloTorch.kt \
       -library $DIR/build/c_interop/TH \
       -o $DIR/build/bin/HelloTorch \
       -linkerOpts "-L$TH_TARGET_DIRECTORY/lib -lTH" || exit 1

echo "Note: You may need to specify LD_LIBRARY_PATH or DYLD_LIBRARY_PATH env variables to $TH_TARGET_DIRECTORY/lib if the TH dynamic library cannot be found."

echo "Artifact path is $DIR/build/bin/HelloTorch.kexe"
