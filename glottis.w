@* The Glottis.

This is where the synthesis of the glottal source signal will be created. 

While the implementation comes directly from Pink Trombone's JavaScript code, 
it should be noted that the glottal model is based on a modified 
LF-model\cite{lu2000glottal}.

@<The Glottis@>=
@<Glottis Initialization@>@\
@<Glottis Computation@>@\

@ Initializiation of the glottis is done inside of |glottis_init|. 

@<Glottis Initialization@>=
static void glottis_init(glottis *glot)
{
    glot->freq = 140; /* 140Hz frequency by default */
    glot->tenseness = 0.6; /* value between 0 and 1 */
}

@ This is where a single sample of audio is computed for the glottis

@<Glottis Computation@>=
static SPFLOAT glottis_compute(glottis *glot)
{
    return 0.0;
}
