# DEPRECATED: Use official libfrpint (>= v1.90) with glib introspection

Example from official repo https://gitlab.freedesktop.org/libfprint/libfprint/-/blob/master/tests/capture.py

More about GLib Introspection: https://pygobject.readthedocs.io/en/latest/

# Requirements

- Cython >= 0.27
- libfprint == 0.99.0

# Install

```
pip install fprintw
```

# Usage

```python
import fprint

fprint.init()
devices = fprint.DiscoveredDevices()

if len(devices) > 0:
    dev = devices[0].open_device()
    print_data = dev.enroll_finger_loop()
    print_data = fprint.PrintData.from_data(print_data.data)
    result = dev.verify_finger_loop(print_data)
    assert result is True
    dev.close()
```
