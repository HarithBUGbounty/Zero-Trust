g++ -std=c++17 -O2 -fstack-protector-all -D_FORTIFY_SOURCE=2 ^
    -fPIE -Wl,-z,relro,-z,now -static -s ^
    -o secure_gatekeeper.exe Zero-Trust.cpp

:: Auto-elevate .exe via manifest injection (requires mt.exe from Windows SDK)
mt.exe -manifest elevate.manifest -outputresource:secure_gatekeeper.exe;1