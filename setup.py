#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""The setup script."""

from setuptools import setup, find_packages

with open('README.rst') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read()

requirements = [
    'Click>=7.0',
]

setup_requirements = [

]

development_requirements = [
    "bumpversion==0.5.3",
    "flake8",
    "wheel==0.32.1",
    "watchdog==0.9.0",
    "coverage==4.5.1",
    "twine==1.12.1",
]

test_requirements = [
    'pytest >= 3.7.4',
    'pytest-cov',
]

setup(
    author="Robert G Johnson Jr",
    author_email='github@oakensoul.com',
    description="Python backed automation for installation of personal config files, tools, and settings",
    keywords='dotfiles configuration tools automation settings',
    name='dotfiles',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Environment :: Console',
        'Intended Audience :: Developers',
        'Intended Audience :: System Administrators',
        'License :: OSI Approved :: MIT License',
        'Natural Language :: English',
        'Programming Language :: Python :: 3.7',
        'Topic :: Utilities'
    ],
    entry_points={
        'console_scripts': [
            'dotfiles=dotfiles.cli:main',
        ],
    },
    extras_require={
        'testing': test_requirements,
        'development': development_requirements,
    },
    install_requires=requirements,
    license="MIT license",
    long_description=readme + '\n\n' + history,
    include_package_data=True,
    packages=find_packages(include=['dotfiles']),
    setup_requires=setup_requirements,
    tests_require=test_requirements,
    test_suite='tests',
    url='https://github.com/oakensoul/dotfiles',
    version='0.1.0',
    zip_safe=False,
)
