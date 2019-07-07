#!/bin/sh

# clear the temp pubic directory
rm -rf public

# Generate static website. Files will be placed in public folder
hugo
