#!/bin/bash

while true
do
    wget -qO - http://en.wikipedia.org/wiki/Special:Random | grep '<title>.*</title>' | sed -e 's/<title>\(.*\) - Wikipedia,.*encyclopedia<\/title>/\1/' | sed -e 's/<[^>]*>//g'
done
