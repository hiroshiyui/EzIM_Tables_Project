#!/bin/bash
cat ez.txt.table | sed  's/$/\t1000/g' > ezbig.txt.table.ibus
cat ezsmall.txt.table | sed  's/$/\t1000/g' > ezsmall.txt.table.ibus
cat ezmid.txt.table | sed  's/$/\t1000/g' > ezmid.txt.table.ibus
cat ezbig.txt.table | sed  's/$/\t1000/g' > ezbig.txt.table.ibus
