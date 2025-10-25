#!/usr/bin/env sh

echo "Executable Filename: $1"
sbcl --load "common_lisp_sbcl.asd" --eval "(ql:quickload :c4x-bot)" --eval "(c4x-bot::create-executable \"$1\")"
