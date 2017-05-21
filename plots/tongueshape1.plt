set terminal eps
unset key
set offsets 0, 0, 0.1, 0
set title "Tract of tongueshape(20.5, 3.5)"
set output "plots/tongueshape1.eps"
plot "plots/tongueshape1.dat" with lines
