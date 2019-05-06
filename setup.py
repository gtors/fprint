#!/usr/bin/env python3

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
  name='fprint',
  version='0.2.0',
  ext_modules=cythonize([
    Extension("fprint", 
        sources=["fprint.pyx"],
        libraries=["fprint"]),
    ]),
)
