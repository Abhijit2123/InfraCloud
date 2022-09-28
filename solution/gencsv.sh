#!/bin/bash

if [ $# -eq 0 ];
then
   number=10
else
   number=$1
fi

for i in `seq $number`
do
echo $i, $RANDOM 
done
