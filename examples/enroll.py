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
    # dev: fprint.Device
    dev = ddevs[0].open_device()

    # print_data: Optional[fprint.PrintData]
    print_data = dev.enroll_finger_loop()

    if print_data is None:
        print("Fail")
    else:
        print("Success")

        # Persist fingerprint info
        with open("some_fingerprint", "wb") as fh:
            fh.write(print_data.data)

    dev.close()

fprint.exit()
