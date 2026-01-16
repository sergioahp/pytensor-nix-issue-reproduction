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

pytensor imports setuptools at runtime (not just at build time) in multiple locations:
- `pytensor/link/c/cmodule.py:1710`: `from setuptools._distutils.sysconfig import ...`
- `pytensor/link/c/exceptions.py:1`: `from setuptools.errors import CompileError`

These imports occur during PyTensor's JIT/C compilation functionality, making setuptools a **runtime dependency**, not merely a build backend requirement.

Upstream pytensor declares `setuptools>=59.0.0` as a runtime dependency:
https://github.com/pymc-devs/pytensor/blob/main/pyproject.toml#L29

Without propagating setuptools, `python3.withPackages` environments are missing an import required for normal operation.

## Fix

Add `setuptools` to pytensor's `propagatedBuildInputs` in nixpkgs:

```nix
propagatedBuildInputs = [
  setuptools
  # ... existing runtime deps ...
];
```

**Why `propagatedBuildInputs`**: setuptools is imported at runtime when PyTensor exercises core functionality (JIT compilation). In nixpkgs terms, this is exactly what `propagatedBuildInputs` is for: Python packages that must be present at runtime and importable when the package is used.

## Full Reproduction

See: https://github.com/sergioahp/pytensor-nix-issue-reproduction
