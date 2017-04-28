@* Data Structures and C Structs.
This section contains all the data needed by Voc.

@<Data Structures and C Structs@>=
@<Glottis Data...@>@/
@<Voc Main...@>@/

@ The top-most data structure is |sp_voc|, designed to be an opaque
struct containing all the variables needed for {\it Voc} to work. 
Like all Soundpipe modules, this struct has the prefix "sp". 

@<Voc Main Data Struct@>=

struct sp_voc {
    glottis @, glot; /*The Glottis*/
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
} tract;

