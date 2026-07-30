# ADR-0026: before-image DDL journal

DDL changes span metadata and multiple table/index files, so a single rename cannot make
them atomic. MiniSQL writes durable before-images and a complete file-move plan before
publishing any DDL output. Startup performs undo for PREPARED and cleanup for COMMITTED.
This intentionally conservative protocol precedes integrating catalog changes into the
page-image WAL and gives every crash boundary an explicit recovery rule.
