
# BitcoinKit Issue Fix

## 问题 / Issue
在运行 `pod install` 时，构建 `secp256k1` 库时出现了以下错误：
While running `pod install`, the following error occurred during the `secp256k1` library build:

```
fatal error: /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/lipo: /var/folders/jp/86j3w3fx08j54wjdp81ln0n80000gn/T/tmp.SKt6tdknEr/.build/iphoneos/lib/libsecp256k1.a and /var/folders/jp/86j3w3fx08j54wjdp81ln0n80000gn/T/tmp.SKt6tdknEr/.build/iphonesimulator/lib/libsecp256k1.a have the same architectures (x86_64) and can't be in the same fat output file
```

## 原因 / Cause
这是因为构建的库在 `iphoneos` 和 `iphonesimulator` 中包含相同的架构（如 x86_64），导致 `lipo` 命令无法合并这些库。
This is because the built libraries for `iphoneos` and `iphonesimulator` contain the same architecture (e.g., x86_64), causing the `lipo` command to fail to merge these libraries.

## 解决方法 / Solution
修改 `build_secp256k1.sh` 脚本，确保正确处理架构。具体更改如下：
Modify the `build_secp256k1.sh` script to correctly handle the architectures. The specific changes are as follows:

```sh
#!/bin/sh
set -ex

SCRIPT_DIR=`dirname "$0"`

TDIR=`mktemp -d`
trap "{ cd - ; rm -rf $TDIR; exit 255; }" SIGINT

cd $TDIR

git clone https://github.com/bitcoin-core/secp256k1.git src

CURRENTPATH=`pwd`

TARGETDIR_IPHONEOS="$CURRENTPATH/.build/iphoneos"
mkdir -p "$TARGETDIR_IPHONEOS"

TARGETDIR_SIMULATOR="$CURRENTPATH/.build/iphonesimulator"
mkdir -p "$TARGETDIR_SIMULATOR"

(cd src && ./autogen.sh)
(cd src && ./configure --host=arm-apple-darwin CC=`xcrun -find clang` CFLAGS="-O3 -arch armv7 -arch armv7s -arch arm64 -isysroot `xcrun -sdk iphoneos --show-sdk-path` -fembed-bitcode -mios-version-min=8.0" CXX=`xcrun -find clang++` CXXFLAGS="-O3 -arch armv7 -arch armv7s -arch arm64 -isysroot `xcrun -sdk iphoneos --show-sdk-path` -fembed-bitcode -mios-version-min=8.0" --prefix="$TARGETDIR_IPHONEOS" && make install)
(cd src && ./configure --host=x86_64-apple-darwin CC=`xcrun -find clang` CFLAGS="-O3 -arch x86_64 -isysroot `xcrun -sdk iphonesimulator --show-sdk-path` -fembed-bitcode-marker -mios-simulator-version-min=8.0" CXX=`xcrun -find clang++` CXXFLAGS="-O3 -arch x86_64 -isysroot `xcrun -sdk iphonesimulator --show-sdk-path` -fembed-bitcode-marker -mios-simulator-version-min=8.0" --prefix="$TARGETDIR_SIMULATOR" && make install)

cd -

mkdir -p "$SCRIPT_DIR/../Libraries/secp256k1/lib"
xcrun lipo -create "$TARGETDIR_IPHONEOS/lib/libsecp256k1.a"                    "$TARGETDIR_SIMULATOR/lib/libsecp256k1.a"                    -o "$SCRIPT_DIR/../Libraries/secp256k1/lib/libsecp256k1.a"
cp -rf $TDIR/src/include "$SCRIPT_DIR/../Libraries/secp256k1"

rm -rf $TDIR

exit 0
```
