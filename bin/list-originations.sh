#!/bin/bash

for f in `find . -type f | grep -Ev '(.svn|/\.)'` ; do ORIGINATION_NAME=`svn pg origination-name $f 2>/dev/null`; if [ -n "$ORIGINATION_NAME" ]; then printf "%-*s" 120 "$f"; echo "$ORIGINATION_NAME"; fi; done > ~/originations.txt
cat ~/originations.txt |grep -E 'silk$' | sed -r 's:^\./::' | sed -r 's: .*$::' | sed -r 's:^:     :' | sort
cat ~/originations.txt |grep -E 'silk-companion$' | sed -r 's:^\./::' | sed -r 's: .*$::' | sed -r 's:^:     :' | sort
cat ~/originations.txt |grep -E 'famfamfam$' | sed -r 's:^\./::' | sed -r 's: .*$::' | sed -r 's:^:     :' | sort
cat ~/originations.txt |grep -E 'tango$' | sed -r 's:^\./::' | sed -r 's: .*$::' | sed -r 's:^:     :' | sort
