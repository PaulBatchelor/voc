_voc "./voc.so" fl
_rate var
_seq "0 2 4 7 9 11 12" gen_vals

15 inv 1 sine 0.3 3 biscale _rate set

_rate get metro 1 _seq tseq 48 +  5 6 1 randi 1 sine 0.3 * + mtof 

_rate get metro 0.1 0.01 0.1 tenv 0.0 0.3 scale
_rate get metro 0.1 0.1 0.3 tenv 0.0 _rate get metro 0.3 0.9 trand scale
0.8
_rate get metro tog  
_voc fe  


dup dup 0.9 8000 revsc drop -14 ampdb * dcblk + 

_voc fc
