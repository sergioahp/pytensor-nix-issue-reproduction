"""
Minimal script to reproduce pytensor setuptools runtime dependency issue.

This will fail with:
ModuleNotFoundError: No module named 'setuptools'

When pytensor tries to import setuptools.errors.CompileError
"""

import pymc as pm
import numpy as np

# Create a minimal model
with pm.Model() as model:
    # Simple normal distribution
    x = pm.Normal('x', mu=0, sigma=1)

    # This will trigger pytensor's compilation which needs setuptools
    print("Attempting to sample (this will trigger the error)...")
    idata = pm.sample(draws=100, tune=100, chains=1)

print("Success! If you see this, setuptools is available.")
