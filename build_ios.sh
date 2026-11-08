xcrun -sdk iphoneos clang++ -arch arm64 -isysroot $(xcrun --sdk iphoneos --show-sdk-path) \
    -std=c++17 -fstack-protector-all -D_FORTIFY_SOURCE=2 \
    -pie -fPIE -O2 \
    -o secure_gatekeeper_ios Zero-Trust.cpp