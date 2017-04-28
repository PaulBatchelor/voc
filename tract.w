@* The Vocal Tract.
The vocal tract.

@<The Vocal Tract@>=
@<Vocal Tract Init...@>@/
@<Vocal Tract Computation...@>@/

@ 
@<Vocal Tract Initialization@>=
static void tract_init(sp_data *sp, tract *tr)
{
    int i;
    SPFLOAT diameter, d; /* needed to set up diameter arrays */
    tr->n = 44;
    tr->nose_length = 28;
    tr->nose_start = 17;

    for(i = 0; i < tr->n; i++) {
        if(i < 7 * (SPFLOAT)tr->n / 44 - 0.5) {
            diameter = 0.6;
        } else if( i < 12 * (SPFLOAT)tr->n / 44) {
            diameter = 1.1;
        } else {
            diameter = 1.5;
        }

        tr->diameter[i] = diameter;

    }

    for(i = 0; i < tr->nose_length; i++) {
        d = 2 * ((SPFLOAT)i / tr->nose_length); 
        if(d < 1) {
            diameter = 0.4 + 1.6 * d;
        } else {
            diameter = 0.5 + 1.5*(2-d);
        }
        diameter = MIN(diameter, 1.9);
        tr->nose_diameter[i] = diameter; 
    }
}

@ 
@<Vocal Tract Computation...@>=
static SPFLOAT tract_compute(sp_data *sp, tract *tr, SPFLOAT in)
{
    return 0;
}
