@* Top-level Functions.

Broadly speaking, the top-level functions are in charge of computing
samples for the DSP inner-loop before, after, and during runtime. They get their
name from the fact that they are the top level of abstraction in the program.
These are the functions that get called in the Sporth Unit Generator 
implementation |@<The Sporth Unit...@>|. 



@<Top Level Functions@>=
@<Voc Create@>@/
@<Voc Destroy@>@/
@<Voc Init...@>@/
@<Voc Compute@>@/

@ @<Voc Create@>=
int sp_voc_create(sp_voc **voc)
{
    *voc = malloc(sizeof(sp_voc));
    return SP_OK;
}

@ @<Voc Destroy@>=
int sp_voc_destroy(sp_voc **voc)
{
    free(*voc);
    return SP_OK;
}

@ @<Voc Initialization@>=
int sp_voc_init(sp_data *sp, sp_voc *voc)
{
    glottis_init(&voc->glot, sp->sr); /* initialize glottis */
    return SP_OK;
}

@ @<Voc Compute@>=
int sp_voc_compute(sp_data *sp, sp_voc *voc, SPFLOAT *out)
{
    *out = glottis_compute(sp, &voc->glot);
    return SP_OK;
}
