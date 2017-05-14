@* Small Applications and Examples.

It has been fruitful investment to write small applications to assist in the 
debugging process. Such programs can be used to generate plots or visuals, or 
to act as a simple program to be used with GDB. In addition to debugging, 
these programs are also used to quickly try out concepts or ideas.

@<Applications and Examples@>=
@(debug.c@>@/
@(plot.c@>

@ \subsec{A Simple Program for Non-Realtime Processing}
The example program below is a simple C program using Soundpipe. 
It is a non-realtime program that will either write to a file or to |STDOUT| 
as a Octave/Matlab plot. This program also is suited very well to be used
with GDB for debugging.

The functions needed to call Voc from C in this way are found in the 
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

    sp_out(sp, 0, out);
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

@ \subsec{A Utility for Plotting Data}
The following program below is used to write data files to be read by
GNUplot. The ideal use of this program is to be plot the various tract and
nose shapes found in the section |@<The Vocal Tract@>|, as well as create a 
visual approach to experimentation. 

@(plot.c@>=
#include <soundpipe.h>
#include <string.h>
#include <stdlib.h>
#include "voc.h"

static void plot_tract()
{
    sp_voc *voc;
    sp_data *sp;
    SPFLOAT *tract;
    int size;
    int i;

    sp_create(&sp);
    sp_voc_create(&voc);
    sp_voc_init(sp, voc);

    tract = sp_voc_get_tract_diameters(voc);
    size = sp_voc_get_tract_size(voc);

    for(i = 0; i < size; i++) {
        printf("%i\t%g\n", i, tract[i]);
    }

    sp_voc_destroy(&voc);
    sp_destroy(&sp);
}

int main(int argc, char **argv) 
{
    if(argc < 2) {
        fprintf(stderr, "Usage: %s plots/name.dat\n", argv[0]);
        exit(1);
    }
    if(!strncmp(argv[1], "plots/tract.dat", 100)) {
        plot_tract();
    } else {
        fprintf(stderr, "Could not find plot %s\n", argv[1]);
        exit(1);
    }
    return 0;
}
