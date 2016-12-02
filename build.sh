#!/bin/bash

set -x
set -e

CC=mips-linux-gnu-gcc-5
LD=mips-linux-gnu-ld

$CC -march=r3000 -mfp32 -mabi=32 -c httpasm.S -o httpasm.o
$LD -e main -Ttext 0x80030000 httpasm.o -o httpasm -Map httpasm.map
