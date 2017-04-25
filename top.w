@* Top-level Functions.

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
    glottis_init(&voc->glot); /* initialize glottis */
    return SP_OK;
}

@ @<Voc Compute@>=
int sp_voc_compute(sp_data *sp, sp_voc *voc, SPFLOAT *out)
{
    *out = glottis_compute(&voc->glot);
    return SP_OK;
}
