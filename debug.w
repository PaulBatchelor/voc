@* A Simple C program.

The example below is a simple C program using Soundpipe. It is a non-realtime
program that will either write to a file or to |STDOUT| as a Octave/Matlab
plot. The functions needed to call Voc from C in this way are found in the 
section |@<Top Level...@>|.

@(debug.c@> = 
#include <soundpipe.h>
#include "voc.h"

static void process(sp_data *sp, void *ud)
{
    SPFLOAT out;
    sp_voc *voc = ud;

    sp_voc_compute(sp, voc, &out);

    sp_out(sp, 0, out * 0.3);
}

int main(int argc, char *argv[])
{
    sp_voc *voc;
    sp_data *sp;

    sp_create(&sp);
    sp->len = 44100;
    sp_voc_create(&voc);
    sp_voc_init(sp, voc);
    @q sp_process_plot(sp, voc, process); @>
    sp_process(sp, voc, process);@/
    sp_voc_destroy(&voc);
    sp_destroy(&sp);
    return 0;
}

