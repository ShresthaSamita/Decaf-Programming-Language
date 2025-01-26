#!/bin/bash
cd ..

if [ $# -eq 0 ]; then
  echo "Usage: $0 <file_path>"
  exit 1
fi

file_path="$1"

./run "$file_path"
