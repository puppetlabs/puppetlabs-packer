#!/bin/bash

counter=0
for file in $(find . -name "*.json" | egrep -v '\.vars\.|MAINTAINERS|metadata')
do
    if ! ./packer validate -syntax-only  "$file" &> /dev/null ; then
        echo "$file"
        ./packer validate -syntax-only  "$file"
        let counter=$counter+1
    fi
done
echo $counter failures
exit $counter
