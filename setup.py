from setuptools import setup
from Cython.Build import cythonize

setup(
    ext_modules=cythonize("m3u8_downloader.pyx"),
)