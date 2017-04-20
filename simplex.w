@* Simplex Noise.
One of the components used in {\it Pink Trombone} is a one-dimenional Simplex
noise source. The Simplex noise algorithm can be thought of as a generalized
N-dimensional version of the Perlin noise algorithm, with some improvements
for performance. % CITATION NEEDED
The Simplex noise algorithm has a very simple use case: only the 
1-dimensional version is used. % perlin noise was used in 2d

As it fortunately turns out, there already exists a MIT-licensed C++ implementation of 
the Simplex Noise algorithm. However, since it is in C++, the implementation 
is not suitable for the strictly ANSI-C code restrictions forced here. 
Since the Simplex Class is rather small, and the needs are only for the
one-dimensional case, converting the code needed is a relatively straight-forward 
task.

@<Simplex Noise Algorithm (one-dimensional)@> =

