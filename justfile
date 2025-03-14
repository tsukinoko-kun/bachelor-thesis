#!/usr/bin/env just --justfile

help:
  @just --list

build:
    typst compile main.typ

clean:
    rm -rf *.pdf || true
    rm -rfd dist || true

watch: build
    typst watch main.typ --open
