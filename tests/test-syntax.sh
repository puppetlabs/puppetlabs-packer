#!/bin/bash

counter=0
for file in $(find . -name "*.json" | egrep -v '^vars\.|.(vars|variables).|MAINTAINERS|metadata')
do
    if ! ./packer validate -syntax-only  "$file" &> /dev/null ; then
        echo "$file"
        # we run the validation command again here to get its output 
        ./packer validate -syntax-only  "$file"
        let counter=$counter+1
    fi
done
echo $counter failures
exit $counter
