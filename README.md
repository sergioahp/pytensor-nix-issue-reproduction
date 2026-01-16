# PyTensor Setuptools Runtime Dependency Issue

## Issue Summary

The nixpkgs `python3Packages.pytensor` package is missing `setuptools` as a runtime dependency, causing `ModuleNotFoundError` when using pytensor (and packages that depend on it, like pymc).

## Error

```
ModuleNotFoundError: No module named 'setuptools'
```

PyTensor imports setuptools in multiple places at runtime:

1. **`pytensor/link/c/exceptions.py:1`**:
   ```python
   from setuptools.errors import CompileError as BaseCompileError
   ```

2. **`pytensor/link/c/cmodule.py:1710`**:
   ```python
   from setuptools._distutils.sysconfig import (
       get_config_vars,
       get_python_inc,
   )
   ```

Both imports occur during pytensor's compilation process, making setuptools a required runtime dependency.

## Root Cause

The upstream pytensor project declares `setuptools>=59.0.0` as a runtime dependency in their `pyproject.toml`:
https://github.com/pymc-devs/pytensor/blob/main/pyproject.toml

However, the nixpkgs package does not include this in its `dependencies` or `propagatedBuildInputs`.

## Reproduction Steps

### With PyMC (original error)

1. Enter the development shell:
   ```bash
   nix develop
   ```

2. Run the reproduction script:
   ```bash
   python reproduce_error.py
   ```

3. Observe the error when pytensor attempts to compile code.

### With PyTensor only (simpler reproduction)

1. Enter the pytensor-only shell:
   ```bash
   nix develop .#pytensor-only
   ```

2. Run the simpler reproduction:
   ```bash
   python reproduce_pytensor_only.py
   ```

3. The error occurs immediately when compiling any pytensor function.

## Expected Behavior

The script should run successfully without any import errors.

## Environment

- nixpkgs channel: nixpkgs-unstable
- pytensor version: 2.31.4 (check with `nix eval nixpkgs#python3Packages.pytensor.version`)
- Python version: 3.13

## Workaround

Override pytensor to include setuptools in dependencies:

```nix
(python3.withPackages (ps: with ps; [
  (pymc.overridePythonAttrs (old: {
    dependencies = builtins.map (dep:
      if dep.pname or "" == "pytensor" then
        dep.overridePythonAttrs (oldPytensor: {
          dependencies = (oldPytensor.dependencies or []) ++ [ ps.setuptools ];
        })
      else dep
    ) (old.dependencies or []);
  }))
]))
```

## Fix Required

The nixpkgs `pytensor` package definition should add `setuptools` to its `dependencies` list to match the upstream project's requirements.
