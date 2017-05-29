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

# Add reverberation using the Zita reverberator 
dup dup 1 2 8000 zrev drop -3 ampdb * + 

# close the plugin
_voc fc
