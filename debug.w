@* Small Applications and Examples.

It has been fruitful investment to write small applications to assist in the 
debugging process. Such programs can be used to generate plots or visuals, or 
to act as a simple program to be used with GDB. In addition to debugging, 
these programs are also used to quickly try out concepts or ideas.

@ \subsec{A Program for Non-Realtime Processing}
The example program below is a C program designed out of necessity to debug 
and test Voc. It a program with a simple commandline interface, where
the user gives a "mode" along with set of optional arguments.

The following modes are as follows:

\item{$\bullet$} {\bf audio:} writes an audio file called "test.wav". You
must supply a duration (in samples).
\item{$\bullet$} {\bf plot:} Uses sp\_process\_plot to generate a
matlab/octave compatible program that plots the audio output.
\item{$\bullet$} {\bf tongue:} Will be a test program that experiments with 
parameters manipulating tongue position. This has not yet been written yet.

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

static void run_voc(long len, int type)
{
    sp_voc *voc;
    sp_data *sp;

    sp_create(&sp);
    sp->len = len;
    sp_voc_create(&voc);
    sp_voc_init(sp, voc);

    if(type == 0) {
        sp_process_plot(sp, voc, process);
    } else {
        sp_process(sp, voc, process);
    }

    sp_voc_destroy(&voc);
    sp_destroy(&sp);
}

static void run_tongue(long len)
{

}

int main(int argc, char *argv[])
{
    if(argc < 3) {
        fprintf(stderr, 
                "Usage: %s [plot|audio|tongue] duration (samples)\n", 
                argv[0]);
        exit(0);
    }

    if(!strcmp(argv[1], "plot")) {
        run_voc(atoi(argv[2]), 0);
    } else if(!strcmp(argv[1], "audio")) {
        run_voc(atoi(argv[2]), 1);
    } else if(!strcmp(argv[1], "tongue")) {
        run_tongue(atoi(argv[2]));
    } else {
        fprintf(stderr, "Error: invalid type %s\n", argv[1]);
    }

    return 0;
}

@ \subsec{A Utility for Plotting Data}
The following program below is used to write data files to be read by
GNUplot. The primary use of this program is for generating use plots 
in this document, such as those seen in the section |@<The Vocal Tract@>|.

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

static void plot_nose()
{
    sp_voc *voc;
    sp_data *sp;
    SPFLOAT *nose;
    int size;
    int i;

    sp_create(&sp);
    sp_voc_create(&voc);
    sp_voc_init(sp, voc);

    nose = sp_voc_get_nose_diameters(voc);
    size = sp_voc_get_nose_size(voc);

    for(i = 0; i < size; i++) {
        printf("%i\t%g\n", i, nose[i]);
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
    } else if(!strncmp(argv[1], "plots/nose.dat", 100)) {
        plot_nose();
    } else {
        fprintf(stderr, "Plot: could not find plot %s\n", argv[1]);
        exit(1);
    }
    return 0;
}
