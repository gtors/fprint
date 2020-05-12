# Fprintw

Python wrapper for libfrprint

# Requirements

- Python >= 3.8
- Cython >= 0.27
- Libfprint >= 1.90
- Glibc >= 2.0

# Install

```
pip install fprintw
```

# Usage example

```python
import fprint
import asyncio


# NOTE: asyncio will use GMainLoop (glib) as event loop
ctx = fprint.init_context()


async def main():

    # Open first available fingerprint device
    if not (dev := await ctx.open_first_device())
        print("No devices found")
        return

    # Enroll finger and create fingerprint
    fingerprint = await dev.enroll()

    # Checking the fingerprints created above
    if await dev.verify(fingerprint):
        print("OK")
    else:
        print("You shall not pass!") 


if __name__ == '__main__':
    asyncio.run(main())

```

More examples:

- enroll
- verify
- identify
- load/store fingerprints in sqlite