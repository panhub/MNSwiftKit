#!/bin/bash
# build-simple.sh

# 设置禁用代码签名
export CODE_SIGN_IDENTITY=""
export CODE_SIGNING_REQUIRED="NO"

# 根据架构设置目标
if [ "$(uname -m)" = "arm64" ]; then
    TARGET="arm64-apple-ios-simulator"
    echo "🍎 Apple Silicon 构建"
else
    TARGET="x86_64-apple-ios-simulator" 
    echo "📊 Intel 构建"
fi

# 获取 SDK 路径
SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)

# 构建命令
swift build \
    -Xswiftc "-sdk" -Xswiftc "$SDK_PATH" \
    -Xswiftc "-target" -Xswiftc "$TARGET"

echo "✅ 构建完成"