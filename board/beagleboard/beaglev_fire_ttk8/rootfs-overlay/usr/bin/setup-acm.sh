#!/bin/sh
# setup-acm.sh - Create a USB ACM gadget using configfs and bind it to UDC

set -e
G=/sys/kernel/config/usb_gadget/g1

# Mount configfs if needed
[ -d /sys/kernel/config ] || mkdir -p /sys/kernel/config
mountpoint -q /sys/kernel/config || mount -t configfs none /sys/kernel/config

# Cleanup previous USB gadget
[ -d "$G" ] && { printf '' > "$G/UDC" 2>/dev/null || true; rm -rf "$G"; sleep 1; }

# Create USB gadget
mkdir -p "$G"
echo 0x1d6b > "$G/idVendor" # Linux Foundation ID
echo 0x0104 > "$G/idProduct" # Multifunction Composite Gadget (test product ID)
mkdir -p "$G/strings/0x409" # English (US) strings
echo "beaglev" > "$G/strings/0x409/manufacturer"
echo "gtest" > "$G/strings/0x409/product"
mkdir -p "$G/configs/c.1"
echo 250 > "$G/configs/c.1/MaxPower" # 500mA (units of 2mA)

# Add single ACM function to USB gadget
mkdir -p "$G/functions/acm.0"
ln -s "$G/functions/acm.0" "$G/configs/c.1/"

# Find the first available USB Device Controller and bind the gadget to it.
# This will make the gadget visible to the host.
UDC=$(ls /sys/class/udc 2>/dev/null | head -n1 || true)
[ -n "$UDC" ] && echo "$UDC" > "$G/UDC"
exit 0