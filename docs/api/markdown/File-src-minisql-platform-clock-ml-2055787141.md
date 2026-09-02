# `src/minisql/platform/clock.ml`

[Home](README.md) · [Files](Files.md)

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

Returns the stable diagnostic name of this component. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L32)

<a id="constant-constant-minisql-platform-clock-invalid-argument-const-invalid-argument-9001-src-minisql-platform-clock-ml-1775662459"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Monotonic timing and bounded sleeping used by lock waits and server polling. Durations are expressed in milliseconds and wall-clock adjustments cannot move the monotonic counter backwards.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L12)

<a id="function-function-minisql-platform-clock-isimplemented-function-isimplemented-src-minisql-platform-clock-ml-659937286"></a>
### isImplemented

```ml
function isImplemented()
```

Reports whether this component is implemented. Takes no caller-supplied inputs. Returns a boolean result; invalid input or delegated failures are reported as structured errors.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L44)

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
| `milliseconds` | `dynamic` | — |  |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L22)

<a id="function-function-minisql-platform-clock-targetmilestone-function-targetmilestone-src-minisql-platform-clock-ml-1040525756"></a>
### targetMilestone

```ml
function targetMilestone()
```

Returns the milestone in which this component became available. Takes no caller-supplied inputs. Returns the produced value or propagates a structured error from validation or delegated operations.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/platform/clock.ml#L38)
