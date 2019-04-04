# Lisp Koans
My answer for [lisp koans](https://github.com/google/lisp-koans).

## Requirements

You have `sbcl` installed.

## Running

Check all exercises:

```
sbcl --script contemplate.lsp
```

Run [Greed Game](https://github.com/ashih42/lisp-koans-answer/blob/master/koans/GREED_RULES.txt) with `n` players in SBCL REPL:

```
(load "koans/extra-credit.lsp")
(start-game n)
```
