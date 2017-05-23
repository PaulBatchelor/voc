# It kind of sounds like an angry rant
_voc "./voc.so" fl
100 
8 metro 0.3 maygate 200 * + 0.1 port
30 1 10 jitter + 

0 1 3 randi
0 1 3 20 1 randi randi
0.7
0 
_voc fe

1 metro 0.7 maygate 0.03 port *

dup dup 1 2 8000 zrev drop -10 ampdb * + 

_voc fc
