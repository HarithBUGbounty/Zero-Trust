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
- `` **Exit** — Closes the menu

## License
This project is licensed under MIT license
