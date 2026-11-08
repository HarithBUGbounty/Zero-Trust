$NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android29-clang++ \
    -std=c++17 -fstack-protector-all -D_FORTIFY_SOURCE=2 \
    -pie -fPIE -O2 \
    -o secure_gatekeeper_arm64 Zero-Trust.cpp

# Package into APK or run via termux