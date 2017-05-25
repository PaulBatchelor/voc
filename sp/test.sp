_voc "./voc.so" fl
# frequency
170 8 1 5 jitter + 
# tongue position
0 1 5 randi
# tongue diameter
0 1 20 randi
# breathiness
0.4 0.7 9 randi 
# velum amount
0 
_voc fe 

dup dup 1 2 8000 zrev drop -3 ampdb * + 

_voc fc
