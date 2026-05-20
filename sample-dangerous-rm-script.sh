#!/usr/bin/env bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail


# A sample script with some common issues

my_var="hello world"

if [ "$my_var" = "hello world" ]; then
	echo "Condition met"
fi

# A command that could be problematic without quoting
rm -rf "$1"

# A function with an unused variable and inconsistent indentation
my_function() {
	echo "Inside function"
}

my_function
