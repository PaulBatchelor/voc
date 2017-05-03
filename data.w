@* Data Structures and C Structs.
This section contains all the data needed by Voc.

@<Data Structures and C Structs@>=
@<Glottis Data...@>@/
@<Tract Data...@>@/
@<Voc Main...@>@/

@ The top-most data structure is |sp_voc|, designed to be an opaque
struct containing all the variables needed for {\it Voc} to work. 
Like all Soundpipe modules, this struct has the prefix "sp". 

@<Voc Main Data Struct@>=

struct sp_voc {
    glottis @, glot; /*The Glottis*/
    tract @, tr; /*The Vocal Tract */
};

@ The glottis data structure contains all the variables used by the glottis.
See |@<The Glottis@>| to see the implementation of the glottal sound source.

\item{$\bullet$} |freq| is the frequency
\item{$\bullet$} |tenseness| is the tenseness of the glottis (more or less looks
like a cross fade between voiced and unvoiced sound). It is a value in the
range $[0,1]$.
\item{$\bullet$} |Rd| % is what?
\item{$\bullet$} |waveform_length| provides the period length (in seconds) of
the fundamental frequency, in seconds.
\item{$\bullet$} The waveform position is kept track of in |time_in_waveform|,
in seconds.

% TODO: describe what these variables are
\item{$\bullet$} |alpha|
\item{$\bullet$} |E0|
\item{$\bullet$} |epsilon|
\item{$\bullet$} |shift|
\item{$\bullet$} |delta|
\item{$\bullet$} |Te|
\item{$\bullet$} |omega|
\item{$\bullet$} |T|

@<Glottis Data Structure@>=

typedef struct {
    SPFLOAT @, freq; 
    SPFLOAT @, tenseness; 
    SPFLOAT @, Rd; 
    SPFLOAT @, waveform_length; 
    SPFLOAT @, time_in_waveform;

    SPFLOAT @, alpha;
    SPFLOAT @, E0;
    SPFLOAT @, epsilon;
    SPFLOAT @, shift;
    SPFLOAT @, delta;
    SPFLOAT @, Te;
    SPFLOAT @, omega;

    SPFLOAT @, T;
} glottis;

@ The Tract C struct contains all the data needed for the vocal tract filter.
@<Tract Data@>=
typedef struct {
    int n; 
    @t \indent n is the size, set to 44. @> @/
    SPFLOAT @, diameter[44];
    SPFLOAT @, rest_diameter[44];
    SPFLOAT @, target_diameter[44];
    SPFLOAT @, new_diameter[44];
    SPFLOAT @, R[44]; @t \indent component going right @>@/
    SPFLOAT @, L[44]; @t \indent component going left @>@/
    SPFLOAT @, reflection[45];
    SPFLOAT @, new_reflection[45];
    SPFLOAT @, junction_outL[45];
    SPFLOAT @, junction_outR[45];
    SPFLOAT @, A[44];
    SPFLOAT @, max_amplitude[44];
    
    int nose_length; 
@t \indent The original code here has it at $floor(28 * n/44)$, and since @>
@t n=44, it should be 28.@>@/
    int nose_start; @t \indent $n - nose\_length + 1$, or 17 @>@/
@t tip\_start is a constant set to 32 @>@/
    int tip_start;
    SPFLOAT @, noseL[28];
    SPFLOAT @, noseR[28];
    SPFLOAT @, nose_junc_outL[29];
    SPFLOAT @, nose_junc_outR[29];
    SPFLOAT @, nose_reflection[29];
    SPFLOAT @, nose_diameter[28];
    SPFLOAT @, noseA[28];
    SPFLOAT @, nose_max_amp[28];

    SPFLOAT @, reflection_left;
    SPFLOAT @, reflection_right;
    SPFLOAT @, reflection_nose;
    
    SPFLOAT @, new_reflection_left;
    SPFLOAT @, new_reflection_right;
    SPFLOAT @, new_reflection_nose;

    SPFLOAT @, velum_target;

    SPFLOAT @, glottal_reflection;
    SPFLOAT @, lip_reflection;
    SPFLOAT @, last_obstruction;
    SPFLOAT @, fade;
    SPFLOAT @, movement_speed; @t 15 cm/s @>@\
    SPFLOAT @, lip_output;
    SPFLOAT @, nose_output;
    SPFLOAT @, T;

} tract;

