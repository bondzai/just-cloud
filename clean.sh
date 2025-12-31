#!/bin/bash
rm -f main.go go.mod Makefile Dockerfile readme.md test.txt
mv nest-poc/* .
mv nest-poc/.* .
rm -rf nest-poc
