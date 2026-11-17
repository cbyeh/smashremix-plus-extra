# Vesper model generator

`gen.py` builds the Vesper fighter's model from code: geometry, six colorways, the face
and the effect pictures. It writes an `ssb64_model` work folder, which the importer then
compiles into `main.bin` / `character.bin`.

```sh
# 1. export the base folder (skeleton and part slots come from it)
python scripts/ssb64_model/ssb64_model.py export extra_characters/Cloud EXPORT --no-blend --no-preview
# 2. generate the work folder
SSB64_MODEL=scripts/ssb64_model python scripts/vesper_model/gen.py EXPORT WORK
# 3. compile it (writes the three files and preview sheets into OUT)
python scripts/ssb64_model/import_fighter.py extra_characters/Cloud WORK --out OUT --costumes 6 --preview OUT/previews
```

Copy `main.bin`, `character.bin` and `main_reqlist.txt` from OUT into `extra_characters/Vesper`.
