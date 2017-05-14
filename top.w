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
@<Voc Set Frequency@>@/
@<Voc Get Tract Diameters@>@/
@<Voc Get Tract Size@>@/

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
    tract_init(sp, &voc->tr); /* initialize vocal tract */
    voc->counter = 0;
    return SP_OK;
}

@ @<Voc Compute@>=
int sp_voc_compute(sp_data *sp, sp_voc *voc, SPFLOAT *out)
{
    SPFLOAT vocal_output, glot;
    SPFLOAT lambda1, lambda2;
    int i;

    @q vocal_output = 0; @>
   
    if(voc->counter == 0) {
        for(i = 0; i < 512; i++) {
            vocal_output = 0;
            lambda1 = (SPFLOAT) i / 512;
            lambda2 = (SPFLOAT) (i + 0.5) / 512;
            glot = glottis_compute(sp, &voc->glot, lambda1);
           
            tract_compute(sp, &voc->tr, glot, lambda1);
            vocal_output += voc->tr.lip_output + voc->tr.nose_output;

            tract_compute(sp, &voc->tr, glot, lambda2);
            vocal_output += voc->tr.lip_output + voc->tr.nose_output;
            voc->buf[i] = vocal_output * 0.125;
        }
        tract_reshape(&voc->tr); 
        tract_calculate_reflections(&voc->tr); 
    }

    @q tract_compute(sp, &voc->tr, glot); @>
    @q vocal_output += voc->tr.lip_output + voc->tr.nose_output; @>

    @q tract_compute(sp, &voc->tr, glot); @>
    @q vocal_output += voc->tr.lip_output + voc->tr.nose_output; @>

    *out = voc->buf[voc->counter];
    voc->counter = (voc->counter + 1) % 512;
    return SP_OK;
}

@ The function |sp_voc_set_frequency| sets the fundamental frequency
for the glottal wave.

@<Voc Set Frequency@> =
void sp_voc_set_frequency(sp_voc *voc, SPFLOAT freq)
{
    voc->glot.freq = freq;
}

@ This getter function returns the cylindrical diameters representing 
tract. 

@<Voc Get Tract Diameters@>=
SPFLOAT* sp_voc_get_tract_diameters(sp_voc *voc)
{
    return voc->tr.diameter;
}

@ This getter function returns the size of the vocal tract. 
@<Voc Get Tract Size@>=
int sp_voc_get_tract_size(sp_voc *voc)
{
    return voc->tr.n;
}
