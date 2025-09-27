# Linux Development Setup Guide for FPGA Projects

This guide covers setting up FPGA development on Linux, specifically for WSL2 environments where USB passthrough is required.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Common Issues and Solutions](#common-issues-and-solutions)
- [WSL2 USB Passthrough Setup](#wsl2-usb-passthrough-setup)
- [Linux Environment Setup](#linux-environment-setup)
- [Testing the Setup](#testing-the-setup)
- [Daily Workflow](#daily-workflow)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### Software Requirements

- Windows 11 or Windows 10 with WSL2 enabled
- Ubuntu 24.04 (or compatible Linux distribution) in WSL2
- Administrative access to Windows
- PowerShell (Administrator privileges required)

### Hardware Requirements

- FPGA development board (iCE40, Tang Nano, etc.)
- USB connection to the development board

## Common Issues and Solutions

### Issue 1: Broken Package Dependencies (NVIDIA/CUDA conflicts)

If you encounter apt dependency issues with NVIDIA or CUDA packages:

```bash
# Check for problematic packages
apt list --installed | grep -E "(nvidia|cuda)"

# Force remove all NVIDIA/CUDA packages (if you don't need them)
sudo dpkg --remove --force-depends --force-remove-reinstreq $(apt list --installed 2>/dev/null | grep -E "(nvidia|cuda)" | cut -d/ -f1)

# Clean up
sudo apt update
sudo apt autoremove
```

### Issue 2: Missing USB Utilities

Install essential USB debugging tools:

```bash
# Install usbutils for lsusb and other USB tools
sudo apt update
sudo apt install -y usbutils

# Verify installation
lsusb --version
```

## WSL2 USB Passthrough Setup

WSL2 doesn't have direct access to USB devices by default. You need to use `usbipd-win` to share USB devices from Windows to WSL2.

### Step 1: Install usbipd-win (Windows - Administrator PowerShell)

```powershell
# Install usbipd-win using winget
winget install --interactive --exact dorssel.usbipd-win
```

### Step 2: Identify Your FPGA Board (Windows - Administrator PowerShell)

```powershell
# List all USB devices
usbipd list

# Look for FTDI devices (common in FPGA boards)
# Example output:
# BUSID  VID:PID    DEVICE                           STATE
# 1-1    0403:6010  USB Serial Converter B           Not shared
```

You're looking for devices with VID:PID combinations like:

- `0403:6010` - FTDI FT2232H (dual USB-UART/FIFO)
- `0403:6014` - FTDI FT232H (single HS USB-UART/FIFO)

### Step 3: Bind and Attach the Device (Windows - Administrator PowerShell)

```powershell
# Bind the device (replace 1-1 with your actual BUSID)
usbipd bind --busid 1-1

# Attach to WSL2 (specify your WSL distribution if needed)
usbipd attach --wsl --busid 1-1
```

### Step 4: Verify Device in Linux (WSL2)

```bash
# Check if the device is now visible in Linux
lsusb

# You should see something like:
# Bus 001 Device 002: ID 0403:6010 Future Technology Devices International, Ltd FT2232C/D/H Dual UART/FIFO IC
```

## Linux Environment Setup

### Step 1: Fix USB Permissions

Create udev rules to allow non-root access to FTDI devices:

```bash
# Create udev rules for FTDI devices
sudo tee /etc/udev/rules.d/53-ftdi.rules << 'EOF'
# FTDI devices for FPGA programming
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6010", GROUP="plugdev", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6014", GROUP="plugdev", MODE="0666"
# Additional common FPGA programmer IDs
SUBSYSTEM=="usb", ATTR{idVendor}=="0403", ATTR{idProduct}=="6001", GROUP="plugdev", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="15ba", ATTR{idProduct}=="002a", GROUP="plugdev", MODE="0666"
SUBSYSTEM=="usb", ATTR{idVendor}=="15ba", ATTR{idProduct}=="002b", GROUP="plugdev", MODE="0666"
EOF
```

### Step 2: Apply udev Rules

```bash
# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger

# Verify your user is in the plugdev group
groups
# Should include 'plugdev' in the output

# If not in plugdev group, add yourself:
# sudo usermod -a -G plugdev $USER
# Then log out and back in
```

### Step 3: Verify Permissions

```bash
# Check USB device permissions
ls -l /dev/bus/usb/001/

# The FTDI device should show:
# crw-rw-rw- 1 root plugdev 189, X Sep 26 14:20 00X
```

## Testing the Setup

### Test 1: Build Project

```bash
cd /path/to/your/fpga/project
./fpga build projects/simulate_ice40
```

Expected output should end with:

```
[SUCCESS] Build completed successfully!
```

### Test 2: Program FPGA

```bash
./fpga prog projects/simulate_ice40
```

Expected output should include:

```
init..
cdone: high
reset..
cdone: low
flash ID: 0x20 0x20 0x11 0x00
file size: 32220
erase 64kB sector at 0x000000..
programming..
done.
reading..
VERIFY OK
cdone: high
Bye.
[SUCCESS] Programming completed successfully!
```

## Daily Workflow

### When Starting Development

1. **Connect your FPGA board** to USB
2. **Open Administrator PowerShell** and run:

   ```powershell
   usbipd attach --wsl --busid 1-1
   ```

   (Replace `1-1` with your device's BUSID)

3. **Verify in WSL2**:
   ```bash
   lsusb | grep -i ftdi
   ```

### When Disconnecting

The USB attachment is automatically removed when you unplug the device or close WSL2. No special cleanup needed.

## Automation Script

Create this PowerShell script to automate device attachment:

### attach-fpga.ps1

```powershell
# Automated FPGA USB device attachment for WSL2
# Save this as attach-fpga.ps1 and run when needed

Write-Host "Searching for FTDI FPGA devices..." -ForegroundColor Green

# Common FTDI VID:PID combinations for FPGA boards
$ftdiDevices = @("0403:6010", "0403:6014", "0403:6001")

$foundDevice = $false

foreach ($deviceId in $ftdiDevices) {
    $device = usbipd list | Where-Object { $_ -match $deviceId }

    if ($device -match "(\d+-\d+)") {
        $busid = $matches[1]
        Write-Host "Found FTDI device ($deviceId) at bus $busid" -ForegroundColor Yellow

        # Check if already attached
        if ($device -match "Attached") {
            Write-Host "Device already attached to WSL2" -ForegroundColor Green
        } else {
            Write-Host "Attaching device to WSL2..." -ForegroundColor Blue
            try {
                usbipd attach --wsl --busid $busid
                Write-Host "Successfully attached device!" -ForegroundColor Green
            } catch {
                Write-Host "Failed to attach device. Make sure this is running as Administrator." -ForegroundColor Red
            }
        }
        $foundDevice = $true
        break
    }
}

if (-not $foundDevice) {
    Write-Host "No FTDI device found. Available devices:" -ForegroundColor Red
    usbipd list
    Write-Host "`nMake sure your FPGA board is connected and try:" -ForegroundColor Yellow
    Write-Host "usbipd bind --busid <BUSID>" -ForegroundColor Cyan
}

Read-Host "`nPress Enter to exit"
```

### Usage:

1. Save the script as `attach-fpga.ps1`
2. Right-click PowerShell, "Run as Administrator"
3. Run: `.\attach-fpga.ps1`

## Troubleshooting

### Device Not Found in Windows

```powershell
# Check Device Manager for unknown devices
devmgmt.msc

# Or list all PnP devices
Get-PnpDevice | Where-Object {$_.Status -eq "Error"}
```

### Device Not Visible in WSL2 After Attachment

```bash
# Check if usbipd service is running (Windows)
# In PowerShell (Admin):
# Get-Service usbipd

# Restart WSL2 if needed
# wsl --shutdown
# wsl
```

### Permission Denied Errors

```bash
# Check device permissions
ls -l /dev/bus/usb/*/*

# Check group membership
id

# If needed, manually fix permissions (temporary):
sudo chmod 666 /dev/bus/usb/001/00*
```

### Programming Fails with "Can't find iCE FTDI USB device"

1. **Verify device is attached**:

   ```bash
   lsusb | grep 0403
   ```

2. **Check permissions**:

   ```bash
   ls -l /dev/bus/usb/001/
   ```

3. **Try manual programming** (temporary):

   ```bash
   sudo ./fpga prog projects/simulate_ice40
   ```

4. **If sudo works**, it's a permissions issue - check udev rules

### BUSID Changes After Reboot

The BUSID (like `1-1`) may change after Windows reboots. Always check with:

```powershell
usbipd list
```

## What's Permanent vs. Temporary

### ✅ Permanent (survives reboots)

- Linux package installations and fixes
- udev rules for USB permissions
- usbipd-win installation and device binding
- WSL2 configuration

### ⚠️ Temporary (need to redo)

- USB device attachment to WSL2
- WSL2 USB device availability

### Summary

You only need to run `usbipd attach --wsl --busid X-X` each time you:

- Restart Windows
- Unplug and reconnect the FPGA board
- Restart WSL2

Everything else is a one-time setup!

## Additional Resources

- [usbipd-win GitHub Repository](https://github.com/dorssel/usbipd-win)
- [WSL2 USB Support Documentation](https://learn.microsoft.com/en-us/windows/wsl/connect-usb)
- [FPGA Project Documentation](../README.md)

---

_Last updated: September 26, 2025_
_Tested with: Windows 11, WSL2 Ubuntu 24.04, FTDI FT2232H-based FPGA boards_
