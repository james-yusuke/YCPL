#!/bin/bash
set -e


SRC="../../build/ecc"
DEST="."
if [ ! -f "$SRC" ]; then
    echo "Source file $SRC does not exist."
    exit 1
fi
cp "$SRC" "$DEST"
chmod +x ecc
echo "Copied $SRC to $DEST"


SRC_DIR="sums"
OUT_DIR="build"
mkdir -p "$OUT_DIR"


for ecc_file in "$SRC_DIR"/*.ec; do
    echo "Compiling $ecc_file → $OUT_DIR"
    ./ecc "$ecc_file" -o "$OUT_DIR"
done
echo "=== All .ec compiled to LLVM IR ==="


for ll_file in "$OUT_DIR"/*.ll; do
    base=$(basename "$ll_file" .ll)
    obj_file="$OUT_DIR/$base.o"
    exe_file="$OUT_DIR/$base"

    echo "---- Building and running $ll_file ----"

    
    llc -filetype=obj "$ll_file" -o "$obj_file"

    clang "$obj_file" -fsanitize=address -o "$exe_file"

    echo "Running $exe_file"
    "$exe_file"

    echo "----------------------------"
done

echo "=== ALL DONE ==="
