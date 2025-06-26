import os

from setuptools import setup, find_packages


app_version = os.getenv("DOCKER_ANDROID_VERSION", "test-version")

with open("requirements.txt", "r") as f:
    reqs = f.read().splitlines()

setup(
    name="docker-android",
    version="0.1",
    url="https://github.com/budtmo/docker-android",
    description="CLI for docker-android",
    author="Budi Utomo",
    author_email="budtmo.os@gmail.com",
    install_requires=reqs,
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    py_modules=["cli", "docker-android"],
    entry_points={"console_scripts": "docker-android=app:cli"}
)