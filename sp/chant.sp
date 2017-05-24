_voc "./voc.so" fl

36 0.3 1 4 jitter + mtof 

0.1 1 sine 0 1 biscale 
0.9
0.9
0.3 1 sine 0 1 biscale
_voc fe 36 mtof 70 5 eqfil

dup dup 0.97 10000 revsc drop -14 ampdb * dcblk + 

_voc fc
