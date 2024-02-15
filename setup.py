from setuptools import setup, find_packages

setup(
  name='chromecast-pcm',
  version='0.1.0',
  py_modules=['server'],
  install_requires=[
    "flask",
    "pychromecast",
    "ffmpeg-python"
  ],
)
