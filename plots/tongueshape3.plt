set terminal eps
unset key
set yrange [0:3.5]
set title "Tract of tongueshape(20.5, 2.0)"
set output "plots/tongueshape3.eps"
plot "plots/tongueshape3.dat" with lines
