@* Soundpipe Files.

This section here outlines files specifically needed to fulfil the Soundpipe 
the requirements for being a Soundpipe module. 

The components of a fully implemented Soundpipe module consist of the 
following:

\item{$\bullet$} The core callback code implementing create, destroy, 
initialize, and compute functions (the core of this document)
\item{$\bullet$} An accompanying header file for the core code (see
|$(voc.h@>|) 
\item{$\bullet$} An example file, showcase a simple usecase for the module
in a small C program, using the namespace convenction ex\_FOO.c.
\item{$\bullet$} A metadata file in the form of a Lua table. This file is 
mainly used to generate documentation for Soundpipe, but it is also used
to generate Sporth ugen code.
\item{$\bullet$} A soundpipe test file, using the namespace t\_FOO.c. This 
file gets included with Soundpipe's internal test utility, which implements
a form of unit testing for DSP code.
\item{$\bullet$} A soundpipe performance file, using the namespce p\_FOO.c.
This file get inslucded with Soundpipe's internal performance utiltity, 
used to gauge how computationally expensive a given Soundpipe module is.

\subsec{A small C Example}

Each soundpipe module comes with a small example file showcasing how to use a
module. This one utilizes the macro tongue control outlined in 
|@<Voc Set Tongue Shape@>| to shape the vowel formants. In this case, a 
single LFO is modulating the tract position. 
@(ex_voc.c@>=

#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include "soundpipe.h"

typedef struct {
    sp_voc *voc;
    sp_osc *osc;
    sp_ftbl *ft; 
} UserData;

void process(sp_data *sp, void *udata) {
    UserData *ud = udata;
    SPFLOAT osc = 0, voc = 0;
    sp_osc_compute(sp, ud->osc, NULL, &osc);
    if(sp_voc_get_counter(sp) == 0) {
        osc = 12 + 16 * (0.5 * (osc + 1));
        sp_voc_set_tongue_shape(voc, osc, 2.9);
    }
    sp_voc_compute(sp, ud->voc, &voc);
    sp->out[0] = voc;
}

int main() {
    UserData ud;
    sp_data *sp;
    sp_create(&sp);
    sp_srand(sp, 1234567);

    sp_voc_create(&ud.voc);
    sp_osc_create(&ud.osc);
    sp_ftbl_create(sp, &ud.ft, 2048);

    sp_voc_init(sp, ud.voc);
    sp_gen_sine(sp, ud.ft);
    sp_osc_init(sp, ud.osc, ud.ft, 0);
    ud.osc->amp = 1;
    ud.osc->freq = 0.1;

    sp->len = 44100 * 5;
    sp_process(sp, &ud, process);

    sp_voc_destroy(&ud.voc);
    sp_ftbl_destroy(&ud.ft);
    sp_osc_destroy(&ud.osc);

    sp_destroy(&sp);
    return 0;
}

