# Setup Python with dependencies Action

This action installs Python, upgrades `pip` and optionally installs some extra
dependencies.

Here is an example demonstrating how to use it in a workflow:

```yaml
jobs:
  test:
    name: Test
    runs-on: ubuntu-20.04

    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      - name: Setup Python
        uses: frequenz-floss/gh-action-setup-python-with-deps@v0.x.x
        with:
          version: "3.11"
          dependencies: "mkdocs"
      - name: Run mkdocs
        run: mkdocs --help
```

## Inputs

* `version`: The Python version to use. Required.

   This is passed to the `actions/setup-python` action.

* `dependencies`: The dependencies to install. Default: "".

  This is passed to the `pip install` command as is, without any shell
  escaping. If empty, no dependencies are installed. 
