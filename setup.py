from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize

setup(
  name='fprint',
  version='0.1.0',
  ext_modules=cythonize([
    Extension("fprint", ["fprint.pyx"]),
    ]),
)
