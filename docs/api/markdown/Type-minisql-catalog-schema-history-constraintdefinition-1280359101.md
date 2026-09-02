# `minisql.catalog.schema_history.ConstraintDefinition`

[Home](README.md) · [Source file](File-src-minisql-catalog-schema-history-ml-67428687.md)

<a id="struct-struct-minisql-catalog-schema-history-constraintdefinition-struct-constraintdefinition-src-minisql-catalog-schema-history-ml-1592829577"></a>
## ConstraintDefinition

```ml
struct ConstraintDefinition
```

Defines the constraint definition record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L88)

## Members

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-columns-columns-src-minisql-catalog-schema-history-ml-570894297"></a>
### columns

```ml
columns
```

Columns field of the constraint definition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L94)

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-expressionsql-expressionsql-src-minisql-catalog-schema-history-ml-351261597"></a>
### expressionSql

```ml
expressionSql
```

CHECK expression or partial-index predicate in canonical SQL form.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L96)

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-indexid-indexid-src-minisql-catalog-schema-history-ml-390854701"></a>
### indexId

```ml
indexId
```

Index id field of the constraint definition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L107)

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-indexname-indexname-src-minisql-catalog-schema-history-ml-928553921"></a>
### indexName

```ml
indexName
```

Index name field of the constraint definition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L109)

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-kind-kind-src-minisql-catalog-schema-history-ml-1138764009"></a>
### kind

```ml
kind
```

Kind field of the constraint definition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L92)

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-name-name-src-minisql-catalog-schema-history-ml-80180315"></a>
### name

```ml
name
```

Name field of the constraint definition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L90)

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-ondelete-ondelete-src-minisql-catalog-schema-history-ml-220422001"></a>
### onDelete

```ml
onDelete
```

On delete field of the constraint definition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L103)

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-onupdate-onupdate-src-minisql-catalog-schema-history-ml-286768861"></a>
### onUpdate

```ml
onUpdate
```

On update field of the constraint definition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L105)

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-referencecolumns-referencecolumns-src-minisql-catalog-schema-history-ml-1652126317"></a>
### referenceColumns

```ml
referenceColumns
```

Referenced columns for foreign keys. For index-backed local constraints, this backwards-compatible extension slot stores ordered INCLUDE columns.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L101)

<a id="field-field-minisql-catalog-schema-history-constraintdefinition-referencetable-referencetable-src-minisql-catalog-schema-history-ml-2046781919"></a>
### referenceTable

```ml
referenceTable
```

Reference table field of the constraint definition.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L98)
