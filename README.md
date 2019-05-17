# ggscheme-examples
This repository is used to discuss our ggscheme. 

* `ggscheme.json` defines the structure of our ggscheme. All examples should be based on it
* `./examples/` give us several examples of our version ggscheme. Every example should contain 3 parts: `ggplot2-object`, `ggscheme` and `vega-lite spec`. The `ggplot2-object` and `vega-lite spec` don't need change. But once we amend the `ggscheme.json`, we shoud check the `ggscheme` and make sure it obey the new `ggscheme.json`.
* `README.md`, `DISCUSS.md` and `Wiki` are good places for us to share ideas and log the change on the `ggscheme.json`.

This repository has two purposes:

* Define our ggscheme
* Add some tests and examples for the final package `ggvega`