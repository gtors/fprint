"""
This example shows you how to save a fingerprint to a file.
"""
import fprint

# Initialization of libfprint
fprint.init()


# Discover all fingerprint devices in the system
# ddevs: Sequence[fprint.DiscoveredDevice]
for ddev in tuple(fprint.DiscoveredDevices()):
    print(ddev.driver.full_name)
    

fprint.exit()
