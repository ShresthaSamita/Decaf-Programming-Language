#!/bin/bash
cd ..
make -s
if [ $? -eq 0 ]; then
  echo "BUILD SUCCESSFUL!!"
else
  echo "BUILD Failed!!"
fi
cd workdir
