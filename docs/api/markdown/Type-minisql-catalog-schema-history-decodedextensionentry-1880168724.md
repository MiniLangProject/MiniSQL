# `minisql.catalog.schema_history.DecodedExtensionEntry`

[Home](README.md) · [Source file](File-src-minisql-catalog-schema-history-ml-67428687.md)

<a id="struct-struct-minisql-catalog-schema-history-decodedextensionentry-struct-decodedextensionentry-src-minisql-catalog-schema-history-ml-99997133"></a>
## DecodedExtensionEntry

```ml
struct DecodedExtensionEntry
```

Generic cursor result used by the schema-extension decoder. Keeping each record decoder in its own function avoids a large lexical block with many temporary locals retaining and later clearing the shared payload reference. Defines the decoded extension entry record used by this module.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L350)

## Members

<a id="field-field-minisql-catalog-schema-history-decodedextensionentry-nextoffset-nextoffset-src-minisql-catalog-schema-history-ml-1439865968"></a>
### nextOffset

```ml
nextOffset
```

Next offset field of the decoded extension entry.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L354)

<a id="field-field-minisql-catalog-schema-history-decodedextensionentry-value-value-src-minisql-catalog-schema-history-ml-1938152276"></a>
### value

```ml
value
```

Value field of the decoded extension entry.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/catalog/schema_history.ml#L352)
