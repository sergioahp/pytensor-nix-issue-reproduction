"""
Minimal script to reproduce pytensor setuptools issue without pymc.

This directly triggers pytensor's compilation which needs setuptools.
"""

import pytensor
import pytensor.tensor as pt

# Create a simple computation
x = pt.dscalar('x')
y = x ** 2

# Compile it - this should trigger the error when pytensor
# tries to import from pytensor.link.c.exceptions
print("Attempting to compile (this will trigger the error)...")
f = pytensor.function([x], y)

print("Compiled successfully!")
result = f(3.0)
print(f"Result: {result}")
