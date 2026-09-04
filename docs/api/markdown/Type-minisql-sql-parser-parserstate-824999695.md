# `minisql.sql.parser.ParserState`

[Home](README.md) · [Source file](File-src-minisql-sql-parser-ml-2143788161.md)

<a id="struct-struct-minisql-sql-parser-parserstate-struct-parserstate-src-minisql-sql-parser-ml-1094648187"></a>
## ParserState

```ml
struct ParserState
```

Cursor state for the recursive-descent statement parser and precedence-climbing expression parser. `tokens` always ends with EndOfInput, keeping `index` valid.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L21)

## Members

<a id="field-field-minisql-sql-parser-parserstate-derivedtablecount-derivedtablecount-src-minisql-sql-parser-ml-389624981"></a>
### derivedTableCount

```ml
derivedTableCount
```

Monotonic suffix used to give inline derived tables collision-resistant internal CTE names.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L29)

<a id="field-field-minisql-sql-parser-parserstate-index-index-src-minisql-sql-parser-ml-1106938337"></a>
### index

```ml
index
```

Index of the next token to inspect or consume.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L25)

<a id="field-field-minisql-sql-parser-parserstate-parametercount-parametercount-src-minisql-sql-parser-ml-1630791901"></a>
### parameterCount

```ml
parameterCount
```

Number assigned to the next positional parameter encountered.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L27)

<a id="field-field-minisql-sql-parser-parserstate-tokens-tokens-src-minisql-sql-parser-ml-1251733785"></a>
### tokens

```ml
tokens
```

Immutable token stream produced by the lexer.


[View source](https://github.com/MiniLangProject/MiniSQL/blob/main/src/minisql/sql/parser.ml#L23)
