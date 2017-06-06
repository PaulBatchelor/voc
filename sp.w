@* Soundpipe Files.

This section here outlines files specifically needed to fulfill the Soundpipe 
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

In addition to providing some example code, these short programs often come
in handy with debugging programs like GDB and Valgrind.
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
    if(sp_voc_get_counter(ud->voc) == 0) {
        osc = 12 + 16 * (0.5 * (osc + 1));
        sp_voc_set_tongue_shape(ud->voc, osc, 2.9);
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

@ \subsec{Soundpipe Unit Test}
The prototypical soundpipe unit test will fill a buffer of memory with
samples. The md5 of this buffer is taken, and then compared with a
reference md5. If they match, the signal is sample-accurately identical 
to the reference and the test passes. A test that does not pass can mean
any number of things went wrong, and indicates that the module should be
seriously looked at it.

@(t_voc.c@>=

#include "soundpipe.h"
#include "md5.h"
#include "tap.h"
#include "test.h"

typedef struct {
    sp_voc *voc;
    sp_osc *osc;
    sp_ftbl *ft; 
} UserData;

int t_voc(sp_test *tst, sp_data *sp, const char *hash) 
{
    uint32_t n;
    UserData ud;

    int fail = 0;
    SPFLOAT osc, voc;
    sp_voc_create(&ud.voc);
    sp_osc_create(&ud.osc);
    sp_ftbl_create(sp, &ud.ft, 2048);
    
    sp_voc_init(sp, ud.voc);
    sp_gen_sine(sp, ud.ft);
    sp_osc_init(sp, ud.osc, ud.ft, 0);
    ud.osc->amp = 1;
    ud.osc->freq = 0.1;

    for(n = 0; n < tst->size; n++) {
        /* compute samples and add to test buffer */
        osc = 0; 
        voc = 0;
        sp_osc_compute(sp, ud.osc, NULL, &osc);
        if(sp_voc_get_counter(ud.voc) == 0) {
            osc = 12 + 16 * (0.5 * (osc + 1));
            sp_voc_set_tongue_shape(ud.voc, osc, 2.9);
        }
        sp_voc_compute(sp, ud.voc, &voc);
        sp_test_add_sample(tst, voc);
    }

    fail = sp_test_verify(tst, hash);

    sp_voc_destroy(&ud.voc);
    sp_ftbl_destroy(&ud.ft);
    sp_osc_destroy(&ud.osc);

    if(fail) return SP_NOT_OK;
    else return SP_OK;
}

@ \subsec{Soundpipe Perfomance Test}

The essence of a performance test in Soundpipe consists of running the 
compute function enough times so that some significant computation time 
is taken up. From there it is measured using a OS timing utility like
{\tt time}, and saved to a log file. The timing information from this 
file can be plotted against other soundpipe module times, which can be useful
to see how certain modules perform relative to others. 

@(p_voc.c@>=

#include <stdlib.h>
#include <stdio.h>
#include "soundpipe.h"
#include "config.h"

int main() {
    sp_data *sp;
    sp_create(&sp);
    sp_srand(sp, 12345);
    sp->sr = SR;
    sp->len = sp->sr * LEN;
    uint32_t t, u;
    SPFLOAT out = 0;

    sp_voc *unit[NUM];

    for(u = 0; u < NUM; u++) { 
        sp_voc_create(&unit[u]);
        sp_voc_init(sp, unit[u]);
    }

    for(t = 0; t < sp->len; t++) {
        for(u = 0; u < NUM; u++) sp_voc_compute(sp, unit[u], &out);
    }

    for(u = 0; u < NUM; u++) sp_voc_destroy(&unit[u]);

    sp_destroy(&sp);
    return 0;
}

