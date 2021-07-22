#!/usr/bin/env python
import subprocess


def main():
    grains = {}
    p = subprocess.Popen("lsusb | grep 'Yubico'", shell=True)
    p.communicate()
    print(p.returncode)
    grains["yubikey"] = p.returncode == 0
    return grains
