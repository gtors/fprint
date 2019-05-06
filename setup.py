#!/usr/bin/env python3

from setuptools import setup, Extension
from Cython.Build import cythonize

setup(
    package_dir={'fprint': 'lib'},
    packages=['fprint'],
    ext_modules=cythonize([
        Extension("fprint", 
            sources=["lib/fprint.pyx"],
            libraries=["fprint"]),
        ]
    ),
    package_data={
        '': ['*.pyx', '*.pxd', '*.c'],
    },
    project_urls={
        "Source": "https://github.com/gtors/fprint",
    }
)
