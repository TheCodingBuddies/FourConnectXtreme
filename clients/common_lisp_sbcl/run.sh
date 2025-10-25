#!/usr/bin/env sh

sbcl --eval "(load \"common_lisp_sbcl.asd\")" --eval "(ql:quickload :c4x-bot)" --eval "(in-package :c4x-bot)" --eval "(main)" "$1" "$2"
