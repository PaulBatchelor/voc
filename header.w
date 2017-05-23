@* Header File.
|CTANGLE| will end up generating two files: a single C amalgamation and this
header file. 

This header file exists for individuals who wish to use Voc in their own
programs. Voc follows Soundpipe's hardware-agnostic design, and should be
trivial to throw in any DSP inner loop. 

The contents of the header is fairly minimal. Following a standard 
header guard, the contents consist of:
\smallskip
\item{$\bullet$} a |typedef| around the opaque struct |sp_voc|
\item{$\bullet$} function declarations which adhere to the 4-stage
Soundpipe module lifecycle model. 
\item{$\bullet$} a collection of setter/getter functions to allow to get and
set data from the opaque struct.

Since |Voc| makes use of opaque struct pointers, this header file will need
to declare setter/getter functions for any user parameters. 

@(voc.h@>=
#ifndef SP_VOC
#define SP_VOC
typedef struct sp_voc sp_voc;

int sp_voc_create(sp_voc **voc);
int sp_voc_destroy(sp_voc **voc);
int sp_voc_init(sp_data *sp, sp_voc *voc);
int sp_voc_compute(sp_data *sp, sp_voc *voc, SPFLOAT *out);

void sp_voc_set_frequency(sp_voc *voc, SPFLOAT freq);

SPFLOAT* sp_voc_get_tract_diameters(sp_voc *voc);
int sp_voc_get_tract_size(sp_voc *voc);
SPFLOAT* sp_voc_get_nose_diameters(sp_voc *voc);
int sp_voc_get_nose_size(sp_voc *voc);
void sp_voc_set_tongue_shape(sp_voc *voc, 
    SPFLOAT tongue_index,
    SPFLOAT tongue_diameter);
void sp_voc_set_breathiness(sp_voc *voc, SPFLOAT breathiness);

void sp_voc_set_diameters(sp_voc *voc,
    int blade_start,
    int lip_start,
    int tip_start,
    SPFLOAT tongue_index,
    SPFLOAT tongue_diameter,
    SPFLOAT *diameters);

int sp_voc_get_counter(sp_voc *voc);

#endif
