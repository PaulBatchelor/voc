\input macros
\input btxmac 

\startcenter
{\bigfont Voc}

{\mediumfont A vocal tract physical model implementation.}
\stopcenter
\vfil \break
\bigheader{Introduction}

The following document describes {\it Voc}, (which will be) an implementation 
of a vocal tract physical model. 

\subsec{Motivations and Goals}
The human voice is a powerful tool for any composer, second only to silence.
Even an approximation of the voice 
can tap into the entire range of human emotion. This is why
the wind howls, floorboards moan, or R2D2 pouts. For computer musicians and
sound designers alike, creating sonic elements with vocal qualities can give
cold digital sounds a human-like relatable quality; an excellent tool for
engaging an audience. 

% Perhaps talk about "sporth talking on the phone with his mother" patch here

The goal of {\it Voc} is to provide a low level model for producing utterances
and phonemes. It will neither attempt to sing or talk, but it will babble
and chatter. A program which is closely aligned with Voc's scope is Neil 
Thapen's web application 
{\it Pink Trombone}. \cite{pinktrombone} 
In this program, vocal phonemes are generated through directly manipulating a 
virtual vocal tract in continuous time. 


\subsec{Literate Programming}

As an experiment, the author has decided to use {\it literate programming} for
this project. Literate programming, created by Donald Knuth \cite{knuth1992literate}, 
is the concept of melting documentation and code together. What you are reading is also a 
program! 

The biggest advantage of using literate programming for this project is the
ability to use mathematical notation to describe concepts that are implemented. 
The C-language does not lend itself well for comprehensibility when it comes
to DSP, even with comments. Nobody ever learned about DSP from C code alone! 
A very successful example of literate programming is the book {\it Physically Based
Rendering} \cite{pbrt}, which is both a text book and software implementation of a 
physically accurate ray tracer. 

The underlying technology used here is CWEB, the definitive literate programming 
tool developed by Donald Knuth, with some minor adjustments for formatting. 


@* Overview.

This being a literate program, it is necessary to provide a global overview
of the program structure. A Sporth  is said to have
the following components: 

@c
@<Headers@>@/
@<The Glottis@>@/
@<Top Level...@>@/
@<The Sporth Unit Generator Function@>@/
@<Return Function@>@/

@* External Sporth UGens.

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

@i ugen

@ @<Headers@>=
#include <stdlib.h>
#include <soundpipe.h>
#include <sporth.h>

#include "voc.h"

@<Data Structures@>

@ A dynamically loaded sporth unit-generated such as the one defined here 
needs to have a globally accessible function called |sporth_return_ugen|. 
All this function needs to do is return the ugen function, which is of type
|plumber_dyn_func|. 
@<Return Function@>=
@[plumber_dyn_func sporth_return_ugen() @]
{
    return sporth_gain;
}

@i data

@i top

@i glottis

@* References.
\bibliography{ref}
\bibliographystyle{plain}
