# `src/apps/minisql_check/main.ml`

[Home](README.md) · [Files](Files.md)

Provides apps minisql check main facilities for this project.

Package: [`(global)`](Package-global-1952375359.md)

Reachable from entry: **no**

## Imports

- `minisql/tools/check.ml` as `checker` → [src/minisql/tools/check.ml](File-src-minisql-tools-check-ml-1674943447.md)

## Declarations

<a id="function-function-main-function-main-args-src-apps-minisql-check-main-ml-1171506170"></a>
### main

```ml
function main(args)
```

Performs the main operation for the apps minisql check main module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `args` | `dynamic` | — | Command-line or caller-supplied arguments. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/apps/minisql_check/main.ml#L14)
