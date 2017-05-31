set terminal eps
unset key
set offsets 0, 0, 0.1, 0
set title "Tract of tongueshape(24.8, 1.4)"
set output "plots/tongueshape4.eps"
plot "plots/tongueshape4.dat" with lines
