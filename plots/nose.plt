set terminal eps
unset key
set offsets 0, 0, 0.1, 0
set title "Initial Nose Shape"
set output "plots/nose.eps"
plot "plots/nose.dat" with lines
