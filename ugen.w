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

@<The Sporth Unit...@>=
#ifdef BUILD_SPORTH_UGEN
static int sporth_gain(plumber_data *pd, sporth_stack *stack, void **ud)
{
    sp_voc *voc;
    SPFLOAT out;
    SPFLOAT freq;
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

@<Return Function@>@/
#endif

@ 
The first state executed is {\bf creation}, denoted by the macro 
|PLUMBER_CREATE|. This is the state where memory is allocated, tables are
created and stack arguments are checked for validity. 

It is here that the top-level function |@<Voc Crea...@>| is called.

@<Creation@>=

sp_voc_create(&voc);
*ud = voc;
if(sporth_check_args(stack, "f") != SPORTH_OK) {
    plumber_print(pd, "Voc: not enough arguments!\n");    
}
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
freq = sporth_stack_pop_float(stack);
sp_voc_set_frequency(voc, freq);
sp_voc_compute(pd->sp, voc, &out);
sporth_stack_push_float(stack, out);

@ The fourth and final state in a Sporth ugen is {\bf Destruction}, denoted
by |PLUMBER_DESTROY|.  Any memory allocated in |PLUMBER_CREATE| 
should be consequently freed here. 

It is here that the top-level function |@<Voc Dest...@>| is called.
@<Destruction@>=
voc = *ud;
sp_voc_destroy(&voc);

