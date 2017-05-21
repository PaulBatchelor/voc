set terminal eps
unset key
set offsets 0, 0, 0.1, 0
set title "Tract of tongueshape(25.5, 3.5)"
set output "plots/tongueshape2.eps"
plot "plots/tongueshape2.dat" with lines
