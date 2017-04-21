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
Since the Class is rather small, and the needs are only for the
one-dimensional case, converting the code needed is a relatively straight-forward 
task.

A great thing about this particular implementation is that it is 
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
@<Helper Functions for the ...@>@/
@<Noise Subroutine@>@/

@ \subsec{Permutation Table}

Part of the simplex algorithm relies on table lookup. Comments in the code
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

@ \subsec{Helper Functions}

A number of small helper functions are part of the original implementation and
will described in this section. In later iterations of this program, they may be dissolved
back into the main subroutine. 

@<Helper Functions for the Simplex Noise Subroutine@>=
@<Fast Floor Subroutine@>@/
@<Helper Function to Compute Gradients-Dot-Residual Vectors@>@/
@<Hash Function@>@/

@ The function |grad| is a helper function for the simplex noise algorithm.
The descriptions of the function variables come from the original 
code documentation:
\item{$\bullet$} {\it hash} is the hash value.
\item{$\bullet$} {\it x} is distance to the corner.

A note in the comments:
\begincodecomment
These generate gradients of more than unit length. To make
a close match with the value range of classic Perlin noise, the final
noise values need to be rescaled to fit nicely within [-1,1].
(The simplex noise functions as such also have different scaling.)
Note also that these noise functions are the most practical and useful
signed version of Perlin noise.
\endcodecomment

@<Helper Function to ...@>=

static float grad(int32_t hash, float x) 
{
    int32_t h = hash & 0x0F;        /* Convert low 4 bits of hash code */
    float grad = 1.0f + (h & 7);    /* Gradient value 1.0, 2.0, ..., 8.0 */
    if ((h & 8) != 0) grad = -grad; /* Set a random sign for the gradient */
    return (grad * x);            /* Multiply the gradient with the distance*/
}

@ A helper function for hashing is needed for the Simplex noise algorithm. 
It is designed to be a wrapper around the |@<Permutation Table@>|. The function
takes in a single 32-bit integer value to be hashed.

\begincodecomment
This inline function costs around 1ns, and is called N+1 times for a noise of N 
dimension.

Using a real hash function would be better to improve the "repeatability of 256" 
of the above permutation table,
but fast integer Hash functions uses more time and have bad random properties.
\endcodecomment

@<Hash Function@>=
static uint8_t hash(int32_t i) {
    return perm[(uint8_t)i];
}

@ A handrolled floor subroutine is created, and is used inside the 
|@<Noise Subroutine@>|.

\begincodecomment
Computes the largest integer value not greater than the float one

This method is faster than using |(int32_t)std::floor(fp).|

I measured it to be approximately twice as fast:
\smallskip
float:  ~18.4ns instead of ~39.6ns on an AMD APU

double: ~20.6ns instead of ~36.6ns on an AMD APU,
\smallskip
Reference: 

{\it http://www.codeproject.com/Tips/700780/Fast-floor-ceiling-functions}
\endcodecomment
@<Fast Floor...@>=
static int32_t fastfloor(float fp) 
{
    int32_t i = (int32_t)fp;
    return (fp < i) ? (i - 1) : (i);
}

@ \subsec{The Main Subroutine}

The main subroutine for producing one-dimensional simplex noise is displayed
below. It takes only one input value, which is referred to as the "input"
coordinate in the original comments.
One neat thing about it is that it is stateless, making it thread-safe
by definition. 

\begincodecomment
The maximum value of this noise is $8*(3/4)^4 = 2.53125$ A factor of 0.395 
scales to fit exactly within [-1,1]
\endcodecomment

The routine itself for the one dimensional case is only a handful of lines 
(skewing is not needed). 
Using the comments from the original code, the procedure can be described
in the following way:
\medskip
\item{1.} Calculate corners coordinates |i0| and |i1| (nearest integer values).
\item{2.} Find distance to corners with |x0| and |x1|.
\item{3.} Calculate contribution from first and second corners with
|t0| and |t1|, respectively.
\item{4.} Calculate the noise factors |n0| and |n1|.
\item{5.} Multiply and scale so that output is in range $[-1, 1]$.
\medskip

@<Noise Subroutine@>=
static float simplex_noise1d(float x) 
{
    float n0, n1;
    float x0, x1;
    float t0, t1;
    int32_t i0, i1; 
@|
    i0 = fastfloor(x);
    i1 = i0 + 1; 
@|
    x0 = x - i0;
    x1 = x0 - 1.0f;
@|
    t0 = 1.0f - x0*x0;
    t0 *= t0;
    n0 = t0 * t0 * grad(hash(i0), x0);
@|
    t1 = 1.0f - x1*x1;
    t1 *= t1;
    n1 = t1 * t1 * grad(hash(i1), x1);
@|
    return 0.395f * (n0 + n1);
}

