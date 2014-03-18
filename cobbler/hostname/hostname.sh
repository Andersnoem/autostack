#!/bin/bash

lineCount=$(sed -n 1p simpsons.txt)
lineCount=$(($lineCount + 1))
hostname=$(sed -n $(echo $lineCount)p simpsons.txt)
sed -i s/"$(($lineCount - 1))"/"$lineCount"/g simpsons.txt
echo $hostname > /target/etc/hostname
exit 0
