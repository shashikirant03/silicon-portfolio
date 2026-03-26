# Security Policy

## Supported Versions

Currently, only the `main` branch of this repository is actively maintained and evaluated for security and logic vulnerabilities. 

| Version | Supported          |
| ------- | ------------------ |
| `main`  | :white_check_mark: |
| `< 1.0` | :x:                |

## Scope

This repository contains educational RTL (Register Transfer Level) designs, specifically targeting the RISC-V RV32I architecture. While this is a portfolio project, responsible disclosure of bugs that could lead to security vulnerabilities in a physical silicon implementation is highly encouraged. 

Please report issues related to:
* **ISA Non-Compliance:** Unintended behavior for documented opcodes.
* **Illegal Instruction Handling:** Unsafe states triggered by malformed or undefined opcodes.
* **Data Leaks:** Unintended exposure of register or memory states.
* **Denial of Service (DoS):** Logic traps that could permanently halt the Program Counter or cause an unrecoverable state.

*Note: General timing violations or synthesis warnings not directly leading to exploitable behavior should be opened as standard Public Issues, not via the Security policy.*

## Reporting a Vulnerability

We take the security and accuracy of hardware design seriously. If you discover a security vulnerability or a critical logic flaw, please **do not** open a public issue.

Instead, please report it via email to: **shashikiran.thandu03@gmail.com**

### What to include in your report:
* **Module Name:** (e.g., `alu.v`, `control_unit.v`)
* **Description:** A detailed summary of the vulnerability.
* **Reproduction Steps:** Provide the specific 32-bit instruction(s) or waveform conditions that trigger the bug. A snippet from a testbench (`tb_*.v`) demonstrating the failure is highly appreciated.
* **Potential Impact:** Briefly explain how this flaw could be exploited if this core were taped out to physical silicon.

### Response Time
You should expect an acknowledgment of your report within 48 hours. If the vulnerability is verified, a patch will be developed and pushed to the `main` branch, and you will be credited in the commit history and Release Notes for the responsible disclosure.
