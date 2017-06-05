\input macros
\input btxmac 
\input epsf

\startcenter
{\bigfont Voc}
\medskip
{\mediumfont A vocal tract physical model implementation.} 
\subsec{By Paul Batchelor}
Git Hash: 
{\tt
\input version
}
\medskip
\stopcenter
\epsfxsize=40pt
\epsfbox{by-sa.eps}
\vfil \break
\bigheader{Introduction}

The following document describes {\it Voc}, an implementation 
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
Rendering} \cite{pbrt}, which is both a textbook and software implementation of a 
physically accurate ray tracer. 

The underlying technology used here is CWEB, the definitive literate programming 
tool developed by Donald Knuth, with some minor macro adjustments for formatting. 


@* Overview.

In a literate program, it is customary (and somewhat mandatory) to provide 
an "overview" section. This section serves as the entry point in generating
the C amalgamation file |voc.c|. Complying with the constraints of |CWEB|, 
the corresponding sections will appear at the bottom of this section.

\subsec{The Core Voc Components}

|@<Headers@>| is the header section of the C file (not be confused with
the separate header file |@(voc.h@>|. This is where all the system includes,
macros, global data, and structs are declared.

|@<The Glottis@>| is the component of Voc concerned with producing the glottal
excitation signal.

|@<The Vocal Tract@>| is implementation of the physical waveguide of the
vocal tract. 

|@<Top Level...@>| is the section consisting of all public functions for 
controlling Voc, from instantiation to parametric control. 

\subsec{Supplementary Files}

In addition to the main C amalgamation, there are a few other files
that this literate program generates:

|@(debug.c@>| is the debug utility used extensively 
through out the development of Voc, used to debug and test out features.

|@(voc.h@>| is the user-facing header file that goes
along with the C amalgamation. Anyone wishing to use this program will need
this header file along with the C file. 

|@(plot.c@>| is a program that generates dat files, which
can then be fed into gnuplot for plotting. It is used to generate the plots
you see in this document.

|@(ugen.c@>| provides an implementation of Voc as a Sporth unit generator, 
offering 5 dimensions of control. In addition the main Sporth plugin, there
are also smaller unit generators implementing portions of Voc, such as
the vocal tract filter. 

\medskip


@c
@<Headers@>@/
@<The Glottis@>@/
@<The Vocal Tract@>@/
@<Top Level...@>@/

@i data

@i top

@i glottis

@i tract

@i header 

@i debug

@i ugen

@i sp

@* References.
\bibliography{ref}
\bibliographystyle{plain}
