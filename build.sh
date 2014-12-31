#!/bin/bash

dmd $(find -name "*.d" | tr '\n' ' ') -odobj -ofbin/main
