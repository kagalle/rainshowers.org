#!/bin/bash
rsync -e "/usr/bin/ssh" --bwlimit=2000 -av ./public/ kengal8@aquon.dreamhost.com:/home/kengal8/rainshowers.org/
