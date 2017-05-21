set terminal eps
unset key
set offsets 0, 0, 0.1, 0
set title "Initial Tract Shape"
set output "plots/tract.eps"
plot "plots/tract.dat" with lines
