@* Simplex Noise.
One of the components used in {\it Pink Trombone} is a one-dimenional Simplex
noise source. The Simplex noise algorithm can be thought of as a generalized
N-dimensional version of the Perlin noise algorithm, with some improvements
for performance. % CITATION NEEDED
The Simplex noise algorithm has a very simple use case: only the 
1-dimensional version is used. % perlin noise was used in 2d

As it fortunately turns out, there already exists a MIT-licensed C++ implementation of 
the Simplex Noise algorithm by Sebastian Rombauts. 
However, since it is in C++, the implementation 
is not suitable for the strictly ANSI-C code restrictions forced here. 
Since the Simplex Class is rather small, and the needs are only for the
one-dimensional case, converting the code needed is a relatively straight-forward 
task.

A great thing about this particular simplex implementation is that it is 
very well-documented using Doxygen-style in-line comments. These comments
will be preserved whenever possible. Displayed below is the header:

\begincodecomment
This implementation is "Simplex Noise" as presented by 
Ken Perlin at a relatively obscure and not often cited course
session "Real-Time Shading" at Siggraph 2001 (before real
time shading actually took on), under the title "hardware noise".
The 3D function is numerically equivalent to his Java reference
code available in the PDF course notes, although I re-implemented
it from scratch to get more readable code. The 1D, 2D and 4D cases
were implemented from scratch by me from Ken Perlin's text.
\endcodecomment


@<Simplex Noise Algorithm (one-dimensional)@> =

@ Part of the simplex algorithm relies on table lookup. Comments in the code
refer to it as a {\it permutation table}:

\begincodecomment
Permutation table. This is just a random jumble of all numbers 0-255. 
This produce a repeatable pattern of 256, but Ken Perlin stated
that it is not a problem for graphic texture as the noise features disappear
at a distance far enough to be able to see a repeatable pattern of 256.

This needs to be exactly the same for all instances on all platforms,
so it's easiest to just keep it as static explicit data.
This also removes the need for any initialisation of this class.

Note that making this an |uint32_t[]| instead of a |uint8_t[]| might make the
code run faster on platforms with a high penalty for unaligned single
byte addressing. Intel x86 is generally single-byte-friendly, but
some other CPUs are faster with 4-aligned reads.
However, a |char[]| is smaller, which avoids cache trashing, and that
is probably the most important aspect on most architectures.
This array is accessed a *lot* by the noise functions.
A vector-valued noise over 3D accesses it 96 times, and a
float-valued 4D noise 64 times. We want this to fit in the cache!
\endcodecomment

@<Permutation Table@>=
static const uint8_t perm[256] = {
151, 160, 137, 91, 90, 15, 131, 13, 201, 95, 96, 53, 194, 233, 7, 225, 140, 36, 
103, 30, 69, 142, 8, 99, 37, 240, 21, 10, 23, 190, 6, 148, 247, 120, 234, 75, 
0, 26, 197, 62, 94, 252, 219, 203, 117, 35, 11, 32, 57, 177, 33, 88, 237, 149, 
56, 87, 174, 20, 125, 136, 171, 168, 68, 175, 74, 165, 71, 134, 139, 48, 27, 
166, 77, 146, 158, 231, 83, 111, 229, 122, 60, 211, 133, 230, 220, 105, 92, 41, 
55, 46, 245, 40, 244, 102, 143, 54, 65, 25, 63, 161, 1, 216, 80, 73, 209, 76, 
132, 187, 208, 89, 18, 169, 200, 196, 135, 130, 116, 188, 159, 86, 164, 100, 
109, 198, 173, 186, 3, 64, 52, 217, 226, 250, 124, 123, 5, 202, 38, 147, 118, 
126, 255, 82, 85, 212, 207, 206, 59, 227, 47, 16, 58, 17, 182, 189, 28, 42, 
223, 183, 170, 213, 119, 248, 152, 2, 44, 154, 163, 70, 221, 153, 101, 155, 
167, 43, 172, 9, 129, 22, 39, 253, 19, 98, 108, 110, 79, 113, 224, 232, 178, 
185, 112, 104, 218, 246, 97, 228, 251, 34, 242, 193, 238, 210, 144, 12, 191, 
179, 162, 241, 81, 51, 145, 235, 249, 14, 239, 107, 49, 192, 214, 31, 181, 199, 
106, 157, 184, 84, 204, 176, 115, 121, 50, 45, 127, 4, 150, 254, 138, 236, 205, 
93, 222, 114, 67, 29, 24, 72, 243, 141, 128, 195, 78, 66, 215, 61, 156, 180
};
