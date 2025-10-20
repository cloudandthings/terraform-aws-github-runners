#!/bin/bash

# mise
mise trust -a
mise install

# pre-commit
pre-commit install

# Python
if [ -f requirements.txt ]; then
	pip install -r requirements.txt
fi
