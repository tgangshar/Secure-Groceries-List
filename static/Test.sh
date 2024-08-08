#!/bin/bash

read -p "Do you Want to create a new Instance (Y|N): " VAR1

if [ "$VAR1" = "Y" ]; then
   read -p "Instance Name: " instance
   echo deleting Compute any Instance: $instance
   echo compute instances delete $instance

   echo Creating New Instance: $instance
else
    echo "Strings are not equal."
   sleep 3
fi
sleep 10