+++
Description = ""
Tags = []
date = "2019-02-26T22:13:00-05:00"
title = "Mouse Speed in Xorg"
+++

Slowing down Logitech mouse speed in Xorg.<!--more-->

Sharing a script to run to slow down the pointer speed of a Logitech mouse.

```text
#!/bin/bash
re1="[^=]*=([0-9]+)"
idline=$(xinput list | grep "Logitech USB Optical Mouse")
if [[ $idline =~ $re1 ]]; then id=${BASH_REMATCH[1]}; fi
#echo $id

re2="[^(]*\(([0-9]+)\)"
matrixline=$(xinput list-props $id | grep "Coordinate Transformation Matrix")
if [[ $matrixline =~ $re2 ]]; then mat=${BASH_REMATCH[1]}; fi
#echo $mat
xinput set-prop $id $mat 0.600000, 0.000000, 0.000000, 0.000000, 0.600000, 0.000000, 0.000000, 0.000000, 1.000000
```

In my case the default value for the first parameter is 1.00; this changes that to be 0.60. The script is needed because, at least on my system, both of those 'id' and 'mat' parameters change over time.
