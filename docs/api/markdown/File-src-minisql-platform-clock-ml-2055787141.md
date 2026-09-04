# `src/minisql/platform/clock.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql platform clock facilities for this project.

Package: [`minisql.platform.clock`](Package-minisql-platform-clock-10633347.md)

Reachable from entry: **yes**

## Imports

- `std/time.ml` as `time_api` → `../MiniLangCompilerML/std/time.ml` — external dependency

## Declarations

<a id="function-function-minisql-platform-clock-componentname-function-componentname-src-minisql-platform-clock-ml-1959317742"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql platform clock module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L33)

<a id="constant-constant-minisql-platform-clock-invalid-argument-const-invalid-argument-9001-src-minisql-platform-clock-ml-1775662459"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Monotonic timing and bounded sleeping used by lock waits and server polling.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L12)

<a id="function-function-minisql-platform-clock-isimplemented-function-isimplemented-src-minisql-platform-clock-ml-659937286"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql platform clock module. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L45)

<a id="function-function-minisql-platform-clock-monotonicmilliseconds-function-monotonicmilliseconds-src-minisql-platform-clock-ml-327030482"></a>
### monotonicMilliseconds

```ml
function monotonicMilliseconds()
```

Performs the monotonic milliseconds operation for this module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L16)

<a id="function-function-minisql-platform-clock-sleepmilliseconds-function-sleepmilliseconds-milliseconds-src-minisql-platform-clock-ml-814445634"></a>
### sleepMilliseconds

```ml
function sleepMilliseconds(milliseconds)
```

Performs the sleep milliseconds operation for this module. Inputs: `milliseconds`. Returns the produced value or propagates a structured error from validation or delegated operations.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `milliseconds` | `dynamic` | — | milliseconds value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L23)

<a id="function-function-minisql-platform-clock-targetmilestone-function-targetmilestone-src-minisql-platform-clock-ml-1040525756"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql platform clock module. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L39)
