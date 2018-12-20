"""
This example shows you how to save a fingerprint to a file.
"""
import fprint

# Initialization of libfprint
fprint.init()


# Discover all fingerprint devices in the system
# ddevs: Sequence[fprint.DiscoveredDevice]
ddevs = fprint.DiscoveredDevices()
if len(ddevs) > 0:
    
    # Choose the first one
    # ddev: fprint.DiscoveredDevice
    ddev = ddevs[0]
    # dev: fprint.Device
    dev = fprint.Device.open(ddev)

    # print_data: Optional[fprint.PrintData]
    print_data = dev.enroll_finger()[0]

    if print_data is None:
        print("Fail")
    else:
        print("Success")

        # Persist fingerprint info
        with open("some_fingerprint", "wb") as fh:
            fh.write(print_data.data)

    dev.close()

fprint.exit()
