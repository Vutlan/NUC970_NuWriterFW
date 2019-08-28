#!/bin/bash

version=`date +%y%m%d`
version+="00"

fwfile="$(winepath NuWriterFW_64MB_gcc.bin)"
romh="$(winepath romh.exe)"

# ROMH <Image_File> <EXE_Address> <FW_Version>
# <FW_Version> = YYMMDDVV
wine "$romh" "$fwfile" 0x03f00040 $version
mv xusb.bin xusb64.bin
rm NuWriterFW_64MB_gcc.bin
