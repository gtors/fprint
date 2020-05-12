from setuptools import  Extension
from Cython.Build import cythonize


def build(setup_kwargs):
    setup_kwargs.update(
        {
            "ext_modules": cythonize([
                Extension(
                    "fprint", 
                    sources=["lib/fprint.pyx"], 
                    libraries=["fprint-2", "glib-2.0"],
                    include_dirs=["/usr/include/glib-2.0", "/usr/lib/glib-2.0/include", "/usr/include/libfprint-2"]
                ),
            ]),
            "package_data": {'': ['*.pyx', '*.pxd', '*.c']},
            "package_dir": {'fprint': 'lib'},
            "packages": ['fprint'],
        }
    )
