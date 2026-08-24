# Setup Python with dependencies Action

This action installs Python, upgrades `pip` and optionally installs some extra
dependencies.

Here is an example demonstrating how to use it in a workflow:

```yaml
jobs:
  test:
    name: Test
    runs-on: ubuntu-24.04

    steps:
      - name: Checkout code
        uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - name: Setup Python
        uses: frequenz-floss/gh-action-setup-python-with-deps@bc560ff517d3606e1291eed46a603a9f7bfe8697 # v1.0.3
        with:
          python-version: "3.11"
          dependencies: "mkdocs"
      - name: Run mkdocs
        run: mkdocs --help
```

## Inputs

* `python-version`: The Python version to use. Required.

   This is passed to the
   [`actions/setup-python`](https://github.com/actions/setup-python) action.

* `dependencies`: The dependencies to install. Default: `""`.

  A whitespace-separated list of dependencies passed to `pip install`. If empty,
  no dependencies are installed.

  **Supported:**

  - Standard package names and version specifiers (e.g., `pytest`,
    `requests>=2.0`, `mkdocs[all]`).
  - Local wheel files (`.whl`), including safe glob patterns (e.g.,
    `dist/*.whl`).

  **Not Supported (Blocked for Security):**
  To prevent arbitrary code execution from untrusted checked-out code in
  `pull_request_target` workflows, the following are explicitly blocked:

  - Editable installs (`-e`, `--editable`).
  - Requirement files (`-r`, `--requirement`).
  - Constraint files (`-c`, `--constraint`).
  - Local source directory installations (e.g., `.`, `./pkg`).
  - Local source distributions (`.tar.gz`, `.zip`).
  - Local file URLs (`file://`).

  **Security Features:**

  - **Safe Execution:** This action runs Python in isolated mode (`python -I`),
    which ignores the current working directory. This prevents path hijacking
    attacks where a malicious `pip.py` could shadow the legitimate `pip`
    module.
  - **Safe Argument Parsing:** The `dependencies` input is parsed and
    glob-expanded safely without shell `eval` or interpolation, preventing
    shell command injection.
