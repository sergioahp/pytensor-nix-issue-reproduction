# pytensor: Missing setuptools runtime dependency

## Package

`python3Packages.pytensor` (version 2.31.4)

## Problem

pytensor fails at runtime with `ModuleNotFoundError: No module named 'setuptools'` when compiling any function.

## Reproduction

```bash
nix-shell -p 'python3.withPackages (ps: [ps.pytensor])'
```

```python
import pytensor.tensor as pt
x = pt.dscalar('x')
f = pytensor.function([x], x ** 2)  # Fails here
```

**Error:**
```
ModuleNotFoundError: No module named 'setuptools'
  File ".../pytensor/link/c/cmodule.py", line 1710, in std_lib_dirs_and_libs
    from setuptools._distutils.sysconfig import get_config_vars, get_python_inc
```

## Root Cause

pytensor imports setuptools at runtime in multiple locations:
- `pytensor/link/c/cmodule.py:1710`
- `pytensor/link/c/exceptions.py:1`

Upstream pytensor declares `setuptools>=59.0.0` as a runtime dependency:
https://github.com/pymc-devs/pytensor/blob/main/pyproject.toml#L29

## Fix

Add `setuptools` to pytensor's `dependencies` list in nixpkgs.

## Full Reproduction

See: https://github.com/sergioahp/pytensor-nix-issue-reproduction
