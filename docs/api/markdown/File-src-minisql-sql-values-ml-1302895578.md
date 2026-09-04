# `src/minisql/sql/values.ml`

[Home](README.md) · [Files](Files.md)

Provides minisql sql values facilities for this project.

Package: [`minisql.sql.values`](Package-minisql-sql-values-826372004.md)

Reachable from entry: **yes**

## Imports

- `minisql/common/endian.ml` as `endian` → [src/minisql/common/endian.ml](File-src-minisql-common-endian-ml-71280848.md)
- `minisql/sql/ast.ml` as `ast` → [src/minisql/sql/ast.ml](File-src-minisql-sql-ast-ml-1617141018.md)
- `minisql/sql/types.ml` as `types` → [src/minisql/sql/types.ml](File-src-minisql-sql-types-ml-1842329761.md)
- `minisql/storage/row_codec.ml` as `row_codec` → [src/minisql/storage/row_codec.ml](File-src-minisql-storage-row-codec-ml-756043630.md)

## Declarations

<a id="function-function-minisql-sql-values-asint64-function-asint64-value-src-minisql-sql-values-ml-737332393"></a>
### asInt64

```ml
function asInt64(value)
```

Implements as int64 for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L534)

<a id="function-function-minisql-sql-values-asnumber-function-asnumber-value-src-minisql-sql-values-ml-123134847"></a>
### asNumber

```ml
function asNumber(value)
```

Implements as number for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L546)

<a id="function-function-minisql-sql-values-binary-function-binary-value-src-minisql-sql-values-ml-634762315"></a>
### binary

```ml
function binary(value)
```

Implements binary for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L120)

<a id="constant-constant-minisql-sql-values-binding-error-const-binding-error-9020-src-minisql-sql-values-ml-176486440"></a>
### BINDING_ERROR

```ml
const BINDING_ERROR = 9020
```

Defines the binding error constant used by the minisql sql values module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L19)

<a id="function-function-minisql-sql-values-boolean-function-boolean-value-src-minisql-sql-values-ml-1847669239"></a>
### boolean

```ml
function boolean(value)
```

Implements boolean for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L80)

<a id="function-function-minisql-sql-values-cast-function-cast-value-target-src-minisql-sql-values-ml-58038556"></a>
### cast

```ml
function cast(value, target)
```

Casts cast using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `target` | `dynamic` | — | target value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L749)

<a id="function-function-minisql-sql-values-comparenonnull-function-comparenonnull-left-right-src-minisql-sql-values-ml-704586203"></a>
### compareNonNull

```ml
function compareNonNull(left, right)
```

Compares non null using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L560)

<a id="function-function-minisql-sql-values-componentname-function-componentname-src-minisql-sql-values-ml-1091525288"></a>
### componentName

```ml
function componentName()
```

Performs the componentName operation for the minisql sql values module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L809)

<a id="constant-constant-minisql-sql-values-constraint-violation-const-constraint-violation-9021-src-minisql-sql-values-ml-776463147"></a>
### CONSTRAINT_VIOLATION

```ml
const CONSTRAINT_VIOLATION = 9021
```

Defines the constraint violation constant used by the minisql sql values module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L21)

<a id="function-function-minisql-sql-values-convert-function-convert-value-target-src-minisql-sql-values-ml-1249630698"></a>
### convert

```ml
function convert(value, target)
```

Converts convert using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `target` | `dynamic` | — | target value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L668)

<a id="function-function-minisql-sql-values-decimalliteral-function-decimalliteral-textvalue-precision-scale-src-minisql-sql-values-ml-443937442"></a>
### decimalLiteral

```ml
function decimalLiteral(textValue, precision, scale)
```

Implements decimal literal for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textValue` | `dynamic` | — | textValue value consumed by this operation. |
| `precision` | `dynamic` | — | precision value consumed by this operation. |
| `scale` | `dynamic` | — | scale value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L455)

<a id="function-function-minisql-sql-values-decimalpower10-function-decimalpower10-exponent-src-minisql-sql-values-ml-1505069033"></a>
### decimalPower10

```ml
function decimalPower10(exponent)
```

Implements decimal power10 for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `exponent` | `dynamic` | — | exponent value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L327)

<a id="function-function-minisql-sql-values-decimalwordsfromtext-function-decimalwordsfromtext-textvalue-precision-scale-src-minisql-sql-values-ml-1044702230"></a>
### decimalWordsFromText

```ml
function decimalWordsFromText(textValue, precision, scale)
```

Parse a decimal spelling into the exact signed scaled integer used by the row format. No binary floating-point arithmetic, rounding or truncation is used. Values with more non-zero fractional digits than the declared scale are rejected instead of silently changing the user's input. Implements decimal words from text for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textValue` | `dynamic` | — | textValue value consumed by this operation. |
| `precision` | `dynamic` | — | precision value consumed by this operation. |
| `scale` | `dynamic` | — | scale value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L349)

<a id="function-function-minisql-sql-values-decimalwordsfromvalue-function-decimalwordsfromvalue-value-target-src-minisql-sql-values-ml-440033710"></a>
### decimalWordsFromValue

```ml
function decimalWordsFromValue(value, target)
```

Implements decimal words from value for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |
| `target` | `dynamic` | — | target value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L465)

<a id="function-function-minisql-sql-values-doublevalue-function-doublevalue-value-src-minisql-sql-values-ml-229372831"></a>
### doubleValue

```ml
function doubleValue(value)
```

Implements double value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L100)

<a id="function-function-minisql-sql-values-fail-function-fail-code-operation-message-src-minisql-sql-values-ml-1110428499"></a>
### fail

```ml
function fail(code, operation, message)
```

Performs the fail operation for the minisql sql values module. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `dynamic` | — | code value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |
| `message` | `dynamic` | — | Human-readable message associated with the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L41)

<a id="function-function-minisql-sql-values-floatingnumberfromtext-function-floatingnumberfromtext-textvalue-src-minisql-sql-values-ml-374337904"></a>
### floatingNumberFromText

```ml
function floatingNumberFromText(textValue)
```

MiniLang's native toNumber parser accepts ordinary decimal spellings but does not accept scientific notation. SQL approximate-number literals do, so split an optional exponent and apply it explicitly. This keeps ordinary spellings on the compiler's well-tested conversion path while supporting forms such as 1.25e2, 1E-3 and a leading plus sign. Implements floating number from text for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textValue` | `dynamic` | — | textValue value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L230)

<a id="function-function-minisql-sql-values-floatingtextpart-function-floatingtextpart-raw-startoffset-endoffset-operation-src-minisql-sql-values-ml-278412966"></a>
### floatingTextPart

```ml
function floatingTextPart(raw, startOffset, endOffset, operation)
```

Implements floating text part for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `raw` | `dynamic` | — | raw value consumed by this operation. |
| `startOffset` | `dynamic` | — | startOffset value consumed by this operation. |
| `endOffset` | `dynamic` | — | endOffset value consumed by this operation. |
| `operation` | `dynamic` | — | operation value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L206)

<a id="function-function-minisql-sql-values-fromliteral-function-fromliteral-expression-src-minisql-sql-values-ml-1833035212"></a>
### fromLiteral

```ml
function fromLiteral(expression)
```

Implements from literal for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `expression` | `dynamic` | — | expression value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L494)

<a id="function-function-minisql-sql-values-fromstorage-function-fromstorage-typekind-raw-src-minisql-sql-values-ml-699002542"></a>
### fromStorage

```ml
function fromStorage(typeKind, raw)
```

Implements from storage for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeKind` | `dynamic` | — | typeKind value consumed by this operation. |
| `raw` | `dynamic` | — | raw value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L801)

<a id="function-function-minisql-sql-values-fromtruth-function-fromtruth-value-src-minisql-sql-values-ml-930826045"></a>
### fromTruth

```ml
function fromTruth(value)
```

Implements from truth for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L620)

<a id="function-function-minisql-sql-values-int64compare-function-int64compare-left-right-src-minisql-sql-values-ml-1966514211"></a>
### int64Compare

```ml
function int64Compare(left, right)
```

Implements int64 compare for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L516)

<a id="function-function-minisql-sql-values-integer-function-integer-value-src-minisql-sql-values-ml-157772959"></a>
### integer

```ml
function integer(value)
```

Implements integer for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L90)

<a id="constant-constant-minisql-sql-values-invalid-argument-const-invalid-argument-9001-src-minisql-sql-values-ml-794520825"></a>
### INVALID_ARGUMENT

```ml
const INVALID_ARGUMENT = 9001
```

Defines the invalid argument constant used by the minisql sql values module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L15)

<a id="function-function-minisql-sql-values-isimplemented-function-isimplemented-src-minisql-sql-values-ml-416636032"></a>
### isImplemented

```ml
function isImplemented()
```

Returns whether implemented satisfies the condition required by the minisql sql values module. Returns the computed value or operation status. Does not modify its inputs.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L823)

<a id="function-function-minisql-sql-values-isnull-function-isnull-value-src-minisql-sql-values-ml-862467543"></a>
### isNull

```ml
function isNull(value)
```

Returns whether the supplied value satisfies the null condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L129)

<a id="function-function-minisql-sql-values-issqlvalue-function-issqlvalue-value-src-minisql-sql-values-ml-1386510379"></a>
### isSqlValue

```ml
function isSqlValue(value)
```

Returns whether the supplied value satisfies the SQL value condition. Returns the computed value or operation status. Does not modify its inputs.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L49)

<a id="function-function-minisql-sql-values-literalfloat-function-literalfloat-textvalue-src-minisql-sql-values-ml-1468420892"></a>
### literalFloat

```ml
function literalFloat(textValue)
```

Implements literal float for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textValue` | `dynamic` | — | textValue value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L315)

<a id="function-function-minisql-sql-values-literalinteger-function-literalinteger-textvalue-src-minisql-sql-values-ml-588573064"></a>
### literalInteger

```ml
function literalInteger(textValue)
```

Implements literal integer for this module. Requires arguments that satisfy the validation performed below. Returns its result or propagates a structured error from validation or a dependency. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textValue` | `dynamic` | — | textValue value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L191)

<a id="function-function-minisql-sql-values-logicaland-function-logicaland-left-right-src-minisql-sql-values-ml-746979935"></a>
### logicalAnd

```ml
function logicalAnd(left, right)
```

Implements logical and for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L641)

<a id="function-function-minisql-sql-values-logicalnot-function-logicalnot-value-src-minisql-sql-values-ml-1084866511"></a>
### logicalNot

```ml
function logicalNot(value)
```

Implements logical not for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L629)

<a id="function-function-minisql-sql-values-logicalor-function-logicalor-left-right-src-minisql-sql-values-ml-523542947"></a>
### logicalOr

```ml
function logicalOr(left, right)
```

Implements logical or for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `left` | `dynamic` | — | left value consumed by this operation. |
| `right` | `dynamic` | — | right value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L654)

<a id="function-function-minisql-sql-values-nullvalue-function-nullvalue-typekind-src-minisql-sql-values-ml-1122001274"></a>
### nullValue

```ml
function nullValue(typeKind)
```

Implements null value for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeKind` | `dynamic` | — | typeKind value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L58)

<a id="function-function-minisql-sql-values-of-function-of-typekind-value-src-minisql-sql-values-ml-186968325"></a>
### of

```ml
function of(typeKind, value)
```

Implements of for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `typeKind` | `dynamic` | — | typeKind value consumed by this operation. |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L69)

<a id="function-function-minisql-sql-values-parseint64-function-parseint64-textvalue-src-minisql-sql-values-ml-801492804"></a>
### parseInt64

```ml
function parseInt64(textValue)
```

Parses int64 using the supplied inputs. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `textValue` | `dynamic` | — | textValue value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L157)

- [minisql.sql.values.SqlValue](Type-minisql-sql-values-sqlvalue-1424374979.md) — struct
<a id="function-function-minisql-sql-values-targetmilestone-function-targetmilestone-src-minisql-sql-values-ml-1484175934"></a>
### targetMilestone

```ml
function targetMilestone()
```

Performs the targetMilestone operation for the minisql sql values module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L816)

<a id="function-function-minisql-sql-values-text-function-text-value-src-minisql-sql-values-ml-1279910843"></a>
### text

```ml
function text(value)
```

Implements text for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L110)

<a id="function-function-minisql-sql-values-tostorage-function-tostorage-value-src-minisql-sql-values-ml-1627552959"></a>
### toStorage

```ml
function toStorage(value)
```

Implements to storage for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L790)

<a id="function-function-minisql-sql-values-truth-function-truth-value-src-minisql-sql-values-ml-1630780257"></a>
### truth

```ml
function truth(value)
```

Implements truth for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L609)

<a id="constant-constant-minisql-sql-values-type-mismatch-const-type-mismatch-9017-src-minisql-sql-values-ml-1442838810"></a>
### TYPE_MISMATCH

```ml
const TYPE_MISMATCH = 9017
```

Defines the type mismatch constant used by the minisql sql values module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L17)

<a id="constant-constant-minisql-sql-values-u32-base-const-u32-base-4294967296-src-minisql-sql-values-ml-1470758855"></a>
### U32_BASE

```ml
const U32_BASE = 4294967296
```

Defines the u32 base constant used by the minisql sql values module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L23)

<a id="function-function-minisql-sql-values-unsignedmagnitudetosigned-function-unsignedmagnitudetosigned-high-low-negative-src-minisql-sql-values-ml-648787271"></a>
### unsignedMagnitudeToSigned

```ml
function unsignedMagnitudeToSigned(high, low, negative)
```

Implements unsigned magnitude to signed for this module. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `high` | `dynamic` | — | high value consumed by this operation. |
| `low` | `dynamic` | — | low value consumed by this operation. |
| `negative` | `dynamic` | — | negative value consumed by this operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L139)

<a id="function-function-minisql-sql-values-upperascii-function-upperascii-value-src-minisql-sql-values-ml-1332986499"></a>
### upperAscii

```ml
function upperAscii(value)
```

Implements upper ascii for this module. Requires arguments that satisfy the validation performed below. Returns the computed value or operation status. Any side effects are limited to the explicitly invoked dependencies.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `value` | `dynamic` | — | Value consumed or transformed by the operation. |


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/values.ml#L729)
