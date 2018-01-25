# Requirements

- Cython >= 0.27
- libfprint == 0.7.0

# Install

```
pip install git+https://github.com/gtors/fprint#egg=fprint-0.1
```

# Usage

```python
import fprint

fprint.init()
ddevs = fprint.DiscoveredDevices()
if len(ddevs) > 0:
    ddev = ddevs[0]
    dev = Device.open(ddev)
    (print_data, image) = dev.enroll_finger()
    # TODO
```
