\input macros
\startcenter
{\bigfont Voc}

{\mediumfont A vocal tract physical model implementation.}
\stopcenter
@* Custom UGens in Sporth.

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


This being a literate program, it is necessary to provide a global overview
of the program structure. A Sporth  is said to have
the following components: 

@c
@<Headers@>@/
@<The Sporth Unit Generator Function@>@/
@<Return Function@>@/

@* Anatomy of the Sporth Unit Generator.

The entirety of the Sporth unit generator is contained within 
a single subroutine, declared |static| so as to not clutter the global
namespace. The crux of the function is a case switch outlining four unique
states of operation, which define the {\it lifecycle} of a Sporth ugen. These
states are executed in order. 

@<The Sporth Unit...@>=

static int sporth_gain(plumber_data *pd, sporth_stack *stack, void **ud)
{
    foo_data *foo;
    SPFLOAT gain, in;
    switch(pd->mode) {
        case PLUMBER_CREATE:
            @<Creation@>;
            break;
        case PLUMBER_INIT: 
            @<Initialization@>;
            break;

        case PLUMBER_COMPUTE:
            @<Computation@>;
            break;

        case PLUMBER_DESTROY:
            @<Destruction@>;
            break;
    }
    return PLUMBER_OK;
}

@ 
The first state executed is {\bf creation}, denoted by the macro 
|PLUMBER_CREATE|. This is the state where memory is allocated, tables are
created and stack arguments are checked for validity. 
@<Creation@>=

if(sporth_check_args(stack, "ff") != SPORTH_OK) {@/
    fprintf(stderr,"Not enough arguments for gain\n");@/
    stack->error++;@/
    return PLUMBER_NOTOK;@/
}@/
foo = malloc(sizeof(foo_data)); /* malloc and assign address to user data */
*ud = foo;
sporth_stack_pop_float(stack);
sporth_stack_pop_float(stack);
sporth_stack_push_float(stack, 0.0);

@ The second state executed is {\bf initialization}, denoted by the macro 
|PLUMBER_INIT|. This is the state where variables get initalised or zeroed out. 
It should be noted that auxiliary memory can allocated here for things 
involving delay lines with user-specified sizes. For this reason, it is
typically not safe to call this twice for reinitialization. (The author admits
that this is not an ideal design choice.)

@<Init...@>=
in = sporth_stack_pop_float(stack);
gain = sporth_stack_pop_float(stack);
sporth_stack_push_float(stack, in * gain);

@ The third state executed is {\bf computation}, denoted by the macro 
|PLUMBER_COMPUTE|. This state happens during Sporth runtime in the
audio loop. Generally speaking, this is where a Ugen will process audio.
In this state, strings in this callback are ignored; only 
floating point values are pushed and popped.

@<Computation@>=
in = sporth_stack_pop_float(stack);
gain = sporth_stack_pop_float(stack);
sporth_stack_push_float(stack, in * gain);

@ The fourth and final state in a Sporth ugen is {\bf Destruction}, denoted
by |PLUMBER_DESTROY|.  Any memory allocated in |PLUMBER_CREATE| 
should be consequently freed here. 
@<Destruction@>=
foo = *ud;
free(foo);

@ @<Headers@>=
#include <stdlib.h>
#include <soundpipe.h>
#include <sporth.h>
/* user data. */
typedef struct {
    int bar;
} foo_data;

@ A dynamically loaded sporth unit-generated such as the one defined here 
needs to have a globally accessible function called |sporth_return_ugen|. 
All this function needs to do is return the ugen function, which is of type
|plumber_dyn_func|. 
@<Return Function@>=
@[plumber_dyn_func sporth_return_ugen() @]
{
    return sporth_gain;
}
