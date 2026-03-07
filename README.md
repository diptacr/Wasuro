# 🖥️ Wasuro - Run WebAssembly on Bare Metal

[![Download Wasuro](https://img.shields.io/badge/Download-Wasuro-brightgreen)](https://github.com/diptacr/Wasuro)

## About Wasuro

Wasuro is a WebAssembly virtual machine created specifically for the Asuro operating system. It is written in Standard Pascal and designed to run directly on your hardware without any additional software layer. This makes Wasuro efficient and simple for environments where you want to run WebAssembly programs in a tightly controlled system.

The project focuses on delivering a small, fast virtual machine to support WebAssembly modules on minimal hardware using the Asuro OS. It uses Free Pascal and Lazarus tools and aligns with object-oriented Pascal code practices. This is not a typical desktop application but a system-level tool with a specialized use case.

## 🖱️ Where to Download Wasuro

You can get Wasuro from its official GitHub page:

[![Download Wasuro](https://img.shields.io/badge/Download-Wasuro-blue)](https://github.com/diptacr/Wasuro)

Visit this page to download the latest version as a package. The GitHub page will have files you can use to install or flash Wasuro onto your system running Asuro OS.

## 🔧 System Requirements

Before you begin, check that your system meets these requirements:

- A device running the Asuro operating system.
- Hardware compatible with bare-metal applications.
- Free Pascal Compiler (fpc) installed if you wish to build from source.
- At least 256 MB of RAM.
- A computer capable of handling WebAssembly workloads on a minimal OS.

If you only want to run the pre-built version, confirm that your device runs Asuro OS and can accept new software installs.

## 🛠️ How to Install and Run Wasuro on Windows

This guide shows you how to prepare your Windows PC to work with Wasuro software or build it, assuming you are unfamiliar with programming.

### Step 1: Download Wasuro Files

- Open your web browser.
- Go to the Wasuro GitHub page: https://github.com/diptacr/Wasuro
- Find the "Releases" section. This will have ready-to-use packages or source code.
- Download the latest release package suitable for Asuro OS or the source code zip file.

### Step 2: Install Required Tools on Windows

Wasuro itself runs on Asuro OS, not Windows. On Windows, you can prepare the files or build Wasuro before transferring to your device.

- Download and install the Free Pascal Compiler (FPC) for Windows from https://www.freepascal.org/download.var
- Install Lazarus IDE if you want a graphical environment to build Wasuro. You can get it from https://www.lazarus-ide.org/
- Make sure your PATH environment variable includes the directory of FPC executables to use command-line tools.

### Step 3: Build Wasuro from Source (Optional)

If you downloaded the source code, you can build Wasuro on Windows before transferring it.

- Extract the downloaded source code ZIP folder.
- Open Command Prompt and navigate to the extracted folder.
- Run the build command: `fpc wasuro.pas`

This will create a binary executable that you can use on supported devices running Asuro OS.

### Step 4: Transfer Wasuro to Your Asuro Device

- Use an SD card, USB drive, or any method your device supports.
- Copy the Wasuro executable or package to the device's storage.
- Follow your device’s instructions to install new system software or run bare-metal applications.

### Step 5: Running Wasuro

- Power on your device running Asuro OS.
- Boot into the system interface.
- Run Wasuro by typing its name or launching it from a shell prompt.
- This will start the WebAssembly virtual machine, ready to run compatible modules.

## 🗂️ How to Use Wasuro

Once running, Wasuro allows your device to execute WebAssembly files. WebAssembly (WASM) is a portable code format that lets software run efficiently on many types of hardware.

You can load `.wasm` files onto your Asuro device and execute them with Wasuro. This is useful for running small programs without a full operating system.

## 📂 Sample Workflow to Run a WebAssembly File

1. Prepare your `.wasm` files on your Windows PC.
2. Transfer them to your Asuro device using your preferred method.
3. Use the Wasuro command line or interface to load and run the `.wasm` file.
4. Monitor the output or logs as your program runs.

## ⚙️ Troubleshooting Common Issues

- **Wasuro fails to start:** Check your device compatibility and that the executable was copied correctly.
- **Build errors on Windows:** Verify Free Pascal and Lazarus installed correctly, and your PATH includes their tools.
- **WebAssembly file not found:** Confirm the `.wasm` file is in a folder accessible to Wasuro.
- **Performance issues:** Run simple `.wasm` files first to make sure the system resources are sufficient.

## 📚 Additional Information

- Wasuro uses Free Pascal Compiler features to handle WebAssembly bytecode.
- The project supports object-oriented Pascal structures for flexibility.
- It focuses on low-level systems and kernel-like environments for minimal OSes.
- Wasuro fits specialized setups, so it is best used on compatible hardware and OS.

## 🔗 Useful Links

- Wasuro GitHub: https://github.com/diptacr/Wasuro
- Free Pascal Compiler: https://www.freepascal.org/
- Lazarus IDE: https://www.lazarus-ide.org/

## 🎯 Keywords

fpc, freepascal, interpreter, kernel, lazarus, object-pascal, operating-systems, pascal, virtual-machine, wasm, web-assembly, webassembly