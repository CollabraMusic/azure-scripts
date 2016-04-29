#!/bin/bash

FILE_PATH=./.env

rm -f $FILE_PATH

for var in "$@"
do
  echo "$var" >> $FILE_PATH  
done

