_voc "./voc.so" fl
170 8 1 5 jitter + 

0 1 5 randi
0 1 20 randi
0.4 0.7 9 randi 
0 
_voc fe 

dup dup 1 2 8000 zrev drop -3 ampdb * + 

_voc fc
