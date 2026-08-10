# 🛠️ x86-64 NASM Hex Dump Utility

![Language](https://img.shields.io/badge/Language-x86__64_Assembly-blue.svg)
![Assembler](https://img.shields.io/badge/Assembler-NASM-orange.svg)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A high-performance, low-level Hex Dump utility written entirely from scratch in **x86-64 Assembly (NASM)** for Linux. 
This project was built to demonstrate a deep understanding of computer architecture, system calls, memory management, and the System V AMD64 ABI calling convention without relying on the C standard library (`libc`).

## 🎯 Project Motivation
The goal of this project was to implement a standard utility (similar to `hexdump`) at the bare-metal level. By bypassing high-level abstractions, this implementation manually handles:
* Direct Linux kernel interactions via raw `syscall` instructions.
* Optimized block-based file reading (chunking) to support files of any size efficiently.
* Manual register-based state management and data formatting.

## ✨ Core Features
* **Zero Dependencies:** Pure assembly implementation with no `libc` overhead.
* **Efficient Memory & I/O:** Uses 1024-byte buffered reading chunks to minimize system calls and memory overhead.
* **Smart ASCII Sanitization:** Automatically detects and replaces non-printable control characters (like newlines or tabs) with dots (`.`) in the side panel for clean terminal visualization.
* **System V ABI Compliant:** Strict adherence to standard 64-bit register-based function calling conventions.

## 🚀 Output Format Example
When running the utility, the binary data is processed into traditional 16-byte formatted lines containing the memory offset, hex representation, and sanitized ASCII view:

```text
00000000: 48 65 6c 6c 6f 20 57 6f 72 6c 64 21 0a 54 68 69  Hello World!.Thi
00000010: 73 20 69 73 20 61 20 74 65 73 74 20 66 69 6c 65  s is a test file
00000020: 2e 0a                                            ..
```

## ⚙️ Prerequisites
To build and run this utility, you need a 64-bit Linux environment equipped with:
* **NASM** (Netwide Assembler)
* **GNU Binutils** (ld linker)

## 🛠️ Build & Run
1. **Clone the repository:**
   ```bash
   git clone https://github.com/idos1234/Assembly-SysLog-Hexer.git
   
   ```
3. **Assemble the source code:**
   ```bash
   nasm -f elf64 main.asm -o main.o
   
   ```
4. **Link the object file:**
   ```bash
   ld main.o -o main

   ```
5. **Run the utility:**
   ```bash
   ./main [your file]

   ```
## 🏛️ Architecture & Internal API
The codebase is modularly structured into specific assembly functions adhering to the System V AMD64 ABI:

| Function | Key Input Registers | Description |
| :--- | :--- | :--- |
| `_open_file` | `RDI` (Filename) | Opens the target file in read-only mode (`SYS_OPEN`) |
| `_read_file` | `RDI` (FD), `RSI` (Buffer) | Reads a data chunk from the file descriptor (`SYS_READ`) |
| `_write_file_hex` | `RSI` (Src), `RDI` (Hex Buf), `RBX` (Len), `R10` (Offset) | Main orchestrator for formatting and printing lines |
| `_print_line_offset`| `RAX` (Line index) | Formats and prints the 8-character hexadecimal address prefix |
| `_print_ascii_sidebar`| `RSI` (String), `RDX` (Length) | Sanitizes control characters and prints the right-side text panel |

## 💡 What I Learned
Building this project provided hands-on experience with:
* Manual stack alignment and preservation of caller/callee-saved registers.
* Implementing base conversion algorithms (decimal to hexadecimal ASCII) at the bit-manipulation level.
* Direct debugging and inspection of raw system outputs in a Linux environment.

## 🗺️ Roadmap
Future improvements planned for this project include:
* Supporting command-line arguments via `argc`/`argv` parsing.
* Adding file output redirection options.
* Implementing a search feature within the hex view.

## 📜 License
This project is open-source and available under the [MIT License](LICENSE).
