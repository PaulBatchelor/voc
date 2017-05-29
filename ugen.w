@* External Sporth Plugins.

In Sporth, one has the ability to dynamically load custom unit-generators
or, {\it ugens}, into Sporth. Such a unit generator can be seen here in 
Sporth code:

\sporthcode{test}

In the code above, the plugin file is loaded via \sword{fl} (function load)
and saved into the table \sword{\_voc}. An instance of \sword{\_voc} is created
with \sword{fe} (function execute). Finally, the dynamic plugin is closed
with \sword{fc} (function close). 

Custom unit generators are written in C using a special interface provided by 
the Sporth API. The functionality of an external sporth ugen is nearly identical
to an internal one, with exceptions being the function definition
and how custom user-data is handled. Besides that, they can be treated as
equivalent. 
\subsec{Anatomy of the Sporth Unit Generator.}

The entirety of the Sporth unit generator is contained within 
a single subroutine, declared |static| so as to not clutter the global
namespace. The crux of the function is a case switch outlining four unique
states of operation, which define the {\it lifecycle} of a Sporth ugen. This
design concept comes from Soundpipe, the music DSP library that Sporth 
is built on top of.

These states are executed in order:

\begingroup
\smallskip
\leftskip=4pc
\item{1.} Create: allocates memory for the DSP module
\item{2.} Initialize: zeros out and sets up default values
\item{3.} Compute: Computes an audio-rate sample (or samples)
\item{4.} Destroy: frees all memory allocated
\par
\endgroup

@(ugen.c@>=
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <soundpipe.h>
#include <sporth.h>
#include "voc.h"

static int sporth_voc(plumber_data *pd, sporth_stack *stack, void **ud)
{
    sp_voc *voc;
    SPFLOAT out;
    SPFLOAT freq;
    SPFLOAT pos;
    SPFLOAT diameter;
    SPFLOAT breath;
    SPFLOAT nasal;

    switch(pd->mode) {
        case PLUMBER_CREATE:@/
            @<Creation@>;
            break;
        case PLUMBER_INIT: @/
            @<Initialization@>;
            break;

        case PLUMBER_COMPUTE: @/
            @<Computation@>;
            break;

        case PLUMBER_DESTROY: @/
            @<Destruction@>;
            break;
    }
    return PLUMBER_OK;
}

@<Return Function@>@/

@ 
The first state executed is {\bf creation}, denoted by the macro 
|PLUMBER_CREATE|. This is the state where memory is allocated, tables are
created and stack arguments are checked for validity. 

It is here that the top-level function |@<Voc Crea...@>| is called.

@<Creation@>=

sp_voc_create(&voc);
*ud = voc;
if(sporth_check_args(stack, "fffff") != SPORTH_OK) {
    plumber_print(pd, "Voc: not enough arguments!\n");    
}
nasal = sporth_stack_pop_float(stack);
breath = sporth_stack_pop_float(stack);
diameter = sporth_stack_pop_float(stack);
pos = sporth_stack_pop_float(stack);
freq = sporth_stack_pop_float(stack);
sporth_stack_push_float(stack, 0.0);

@ The second state executed is {\bf initialization}, denoted by the macro 
|PLUMBER_INIT|. This is the state where variables get initalised or zeroed out. 
It should be noted that auxiliary memory can allocated here for things 
involving delay lines with user-specified sizes. For this reason, it is
typically not safe to call this twice for reinitialization. (The author admits
that this is not an ideal design choice.)

It is here that the top-level function |@<Voc Init...@>| is called.

@<Initialization@>=
voc = *ud;
sp_voc_init(pd->sp, voc);
nasal = sporth_stack_pop_float(stack);
breath = sporth_stack_pop_float(stack);
diameter = sporth_stack_pop_float(stack);
pos = sporth_stack_pop_float(stack);
freq = sporth_stack_pop_float(stack);
sporth_stack_push_float(stack, 0.0);

@ The third state executed is {\bf computation}, denoted by the macro 
|PLUMBER_COMPUTE|. This state happens during Sporth runtime in the
audio loop. Generally speaking, this is where a Ugen will process audio.
In this state, strings in this callback are ignored; only 
floating point values are pushed and popped.

It is here that the top-level function |@<Voc Comp...@>| is called.

@<Computation@>=
voc = *ud;
nasal = sporth_stack_pop_float(stack);
breath = sporth_stack_pop_float(stack);
diameter = sporth_stack_pop_float(stack);
pos = sporth_stack_pop_float(stack);
freq = sporth_stack_pop_float(stack);
sp_voc_set_frequency(voc, freq);
sp_voc_set_breathiness(voc, breath);

if(sp_voc_get_counter(voc) == 0) {
    sp_voc_set_velum(voc, 0.01 + 0.8 * nasal);
    sp_voc_set_tongue_shape(voc, 12 + 16.0 * pos, diameter * 3.5);
}

sp_voc_compute(pd->sp, voc, &out);
sporth_stack_push_float(stack, out);

@ The fourth and final state in a Sporth ugen is {\bf Destruction}, denoted
by |PLUMBER_DESTROY|.  Any memory allocated in |PLUMBER_CREATE| 
should be consequently freed here. 

It is here that the top-level function |@<Voc Dest...@>| is called.
@<Destruction@>=
voc = *ud;
sp_voc_destroy(&voc);

@ A dynamically loaded sporth unit-generated such as the one defined here 
needs to have a globally accessible function called |sporth_return_ugen|. 
All this function needs to do is return the ugen function, which is of type
|plumber_dyn_func|. 
@<Return Function@>=
@[plumber_dyn_func sporth_return_ugen() @]
{
    return sporth_voc;
}
