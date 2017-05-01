@* A Simple C program.

The example below is a simple C program using Soundpipe. It is a non-realtime
program that will either write to a file or to |STDOUT| as a Octave/Matlab
plot. The functions needed to call Voc from C in this way are found in the 
section |@<Top Level...@>|.

@(debug.c@> = 
#include <soundpipe.h>
#include <string.h>
#include <stdlib.h>
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
    int type;

    if(argc < 3) {
        fprintf(stderr, "Usage: %s [plot|audio] duration (samples)\n", argv[0]);
        exit(0);
    }

    if(!strcmp(argv[1], "plot")) {
        type = 0;
    } else if(!strcmp(argv[1], "audio")) {
        type = 1;
    } else {
        fprintf(stderr, "Error: invalid type %s\n", argv[1]);
    }
    sp_create(&sp);
    sp->len = atoi(argv[2]);
    sp_voc_create(&voc);
    sp_voc_init(sp, voc);

    if(type == 0) {
        sp_process_plot(sp, voc, process);
    } else {
        sp_process(sp, voc, process);
    }
    sp_voc_destroy(&voc);
    sp_destroy(&sp);
    return 0;
}

