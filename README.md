# ZeroTrust 🛡

ZeroTrust is a lightweight, cross-platform C/C++ network enforcement utility built around a strict default-deny mindset. Instead of trusting connections by default and trying to catch bad traffic after it happens, ZeroTrust blocks everything first and only lets explicitly approved traffic pass through.

## Why This Works

Most traditional security tools rely on signatures or behavior tracking, which means a brand-new attack can slip through before anyone even knows it exists. ZeroTrust flips that approach around completely. Because every outbound and inbound socket connection is checked against a strict whitelist and validation rules before anything goes through, unknown processes and unauthorized servers simply have nowhere to connect.

By locking down network communication at the socket level, ZeroTrust helps protect your system against:

- **Remote Code Execution (RCE):** Even if an attacker finds a flaw and executes a payload on your machine, the payload cannot reach back out to a command-and-control (C2) server to pull down second-stage tools or take remote instructions.
- **Ransomware:** Stops unauthorized outbound callbacks used to fetch encryption keys, communicate with attacker infrastructure, or spread laterally across your local network.
- **Keyloggers & Spyware:** Captures keystrokes or screen data mean nothing if the malware cannot exfiltrate that data out of your machine. ZeroTrust cuts off unauthorized data leaks before a single byte leaves your device.
- **Unauthorized Background Trackers & Droppers:** Blocks silent background connections from untrusted binaries, scripts, and automatically block the unauthorized user that trying reach it.

## Project structure

```text
zerotrust/
├── .vscode/
│   ├── settings.json
│   ├── tasks.json
│   ├── launch.json
│   └── c_cpp_properties.json
├── src/
│   ├── zerotrust_win.cpp        # Windows (Winsock2)
│   ├── zerotrust_posix.cpp      # Linux / Android (POSIX sockets)
│   └── common.h                 # shared whitelist + validation logic
├── ios/
│   ├── ZeroTrust.xcodeproj/
│   │   └── project.pbxproj
│   └── main.mm                  # iOS scaffold (Obj-C++ wrapper)
├── scripts/
│   ├── setup.bat                # Windows menu
│   ├── setup.sh                 # Linux / macOS menu
│   ├── setup_android.sh         # Android NDK menu
│   └── setup_ios.sh             # iOS menu (macOS host only)
├── build/
│   └── .gitkeep
├── logs/
│   └── .gitkeep
├── Makefile                     # Linux / Android
├── CMakeLists.txt               # cross-platform fallback
└── README.md
```

## How It Is Organized

- **Core Engine (`src/`):** Uses native Winsock2 on Windows (`zerotrust_win.cpp`) and POSIX sockets on Linux and Android (`zerotrust_posix.cpp`), sharing the exact same whitelist and validation rules inside `common.h`.
- **iOS Target (`ios/`):** Includes an Objective-C++ wrapper (`main.mm`) and Xcode project setup so the core logic can run cleanly on iOS.
- **Interactive Menus (`scripts/`):** Dedicated CLI menus for Windows (`setup.bat`), Linux/macOS (`setup.sh`), Android NDK (`setup_android.sh`), and iOS (`setup_ios.sh`) to build binaries, run the utility, inspect logs, and view active whitelist rules.
- **Build & Logs (`build/`, `logs/`):** Keeps compiled binaries and runtime activity logs cleanly separated from your source code.

## Windows Setup Menu

Run `scripts\setup.bat` to open the interactive control menu:

- `` **Build ZeroTrust.exe** — Compiles the Windows binary into `build/`
- `` **Run ZeroTrust.exe** — Starts the enforcement engine
- `` **View log** — Reads recent connection and block logs from `logs/`
- `` **Clear log** — Resets the log files
- `` **Show whitelist** — Displays currently allowed entries
- `` **Exit** — Closes

## Platform Support & iOS Constraints

We get asked a lot: *"If this is a cross-platform Zero-Trust server, why can't I just run it on my iPhone like I do on Android?"*

The short answer is: **Apple's sandbox says no.** 

Here is a human breakdown of how ZeroTrust behaves across the four target operating systems, and exactly why iOS is the odd one out.

### 1. Windows (`ZeroTrust.exe`)
**Status:** Fully Working (Native)
Windows is the primary target. The source uses Winsock2 (`ws2_32.lib`), binds to loopback, and enforces `SO_EXCLUSIVEADDRUSE` so other applications can't hijack the port. It compiles cleanly with MSVC using `/GS` (stack cookies), `/guard:cf` (Control Flow Guard), and `/DYNAMICBASE` (ASLR). You run it as a standard executable, and it sits silently in the background logging connection attempts to `zerotrust.log`.

### 2. Linux (`zerotrust`)
**Status:** Fully Working (POSIX Port)
The Linux build uses standard POSIX sockets (`sys/socket.h`). Because Linux doesn't have `SO_EXCLUSIVEADDRUSE`, we use `SO_REUSEADDR`. It compiles via `g++` with `-fstack-protector-all`, `-D_FORTIFY_SOURCE=2`, and `-Wl,-z,relro,-z,now` (Full RELRO) to harden the binary against memory corruption. It runs as a standard daemon. 

### 3. Android (`zerotrust_arm64`)
**Status:** Fully Working (Root Required)
Android is built on the Linux kernel, so the POSIX port works perfectly. We cross-compile it using the Android NDK for `arm64-v8a`. **The catch:** Android apps run in isolated user IDs. To read network sockets and bind to privileged ports (or even loopback in some newer Android versions), you need root. You push the binary via `adb`, run `su`, and execute it from `/data/local/tmp`. Once running, it behaves exactly like the Linux build.

### 4. iOS (The Wall)
**Status:** Not Runnable via Standard App Store
This is where the "write once, run everywhere" dream dies. Here is why the iOS build won't work on a standard, non-jailbroken iPhone:

1. **The Sandbox:** iOS apps are strictly sandboxed. They cannot open raw sockets or bind to listening ports (`bind()` and `listen()`) without the `com.apple.security.network.server` entitlement. Apple only grants this entitlement to apps that pass a rigorous App Store review (like remote desktop apps or local multiplayer games).
2. **No Background Daemons:** iOS aggressively kills background processes. Even if you could bind the port, the OS would suspend your app the moment the user swipes up to the home screen.
3. **Code Signing:** You cannot just `adb push` a compiled `.mm` (Objective-C++) binary to an iPhone. It must be signed by a valid Apple Developer certificate and provisioned to that specific device's UDID.

**How to actually run it on iOS:**
- **Jailbroken Devices:** If you have a jailbroken iPhone (via unc0ver or palera1n), the sandbox is removed. You can compile `ZeroTrust.mm` as a standalone command-line binary using `clang++` on macOS, `scp` it to the device, and run it from the terminal. 
- **Xcode Debugger:** You can run it from Xcode on a free developer provisioning profile, but it will only stay alive while the debugger is attached.

### Summary
- **Windows, Linux, Android:** Build it, deploy it, run it. The code is hardened, the sockets work, and the whitelist enforces itself.
- **iOS:** The logic is written and compiles, but Apple's OS is designed to prevent exactly this kind of headless, raw-socket networking tool from running unless you jailbreak the hardware.
