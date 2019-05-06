"""
This example shows how to verify a previously saved fingerprint.
"""

import fprint

# Initialization of libfprint
fprint.init()


# Load fingerprint info from a binary file (see enroll.py)
with open('some_fingerprint', 'rb') as fh:
    fingerprint = fprint.PrintData.from_data(fh.read())


# Discover all fingerprint devices in the system
# ddevs: Sequence[fprint.DiscoveredDevice]
ddevs = fprint.DiscoveredDevices()
if len(ddevs) > 0:
    # Choose the first one
    # dev: fprint.Device
    dev = ddevs[0].open_device()

    # Start fingerprint verification. In that moment you should 
    # place your finger on the device.
    # matched: bool 
    matched = dev.verify_finger_loop(fingerprint)

    if matched:
        print("Hooray!")
    else:
        print("Get out, I don't know you...")

    dev.close()

fprint.exit()
