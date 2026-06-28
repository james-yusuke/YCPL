#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 <llvm-ir-file.ll>"
    exit 1
fi

LL_FILE="$1"
OBJ_FILE="program.o"
OUT="program"

llc -filetype=obj "$LL_FILE" -o "$OBJ_FILE"
if [ $? -ne 0 ]; then
    echo "llc failed"
    exit 1
fi

clang "$OBJ_FILE" -o "$OUT"
if [ $? -ne 0 ]; then
    echo "clang failed"
    exit 1
fi

clang "$OBJ_FILE" -fsanitize=address -o "$OUT-asan"
if [ $? -ne 0 ]; then
    echo "clang (ASan) failed"
    exit 1
fi

echo "---- Running ASan build ----"
./"$OUT-asan"
