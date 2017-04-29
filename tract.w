@* The Vocal Tract.
The vocal tract.

@<The Vocal Tract@>=
@<Calculate Vocal Tract Reflections @>@/
@<Calculate Vocal Tract Nose Reflections @>@/
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

    tr->reflection_left = 0.0;
    tr->reflection_right= 0.0;
    tr->reflection_nose = 0.0;
    tr->new_reflection_left = 0.0;
    tr->new_reflection_right= 0.0;
    tr->new_reflection_nose = 0.0;
    tr->velum_target = 0.01;

    memset(tr->diameter, 0, tr->n * sizeof(SPFLOAT));
    memset(tr->rest_diameter, 0, tr->n * sizeof(SPFLOAT));
    memset(tr->target_diameter, 0, tr->n * sizeof(SPFLOAT));
    memset(tr->new_diameter, 0, tr->n * sizeof(SPFLOAT));
    memset(tr->L, 0, tr->n * sizeof(SPFLOAT));
    memset(tr->R, 0, tr->n * sizeof(SPFLOAT));
    memset(tr->reflection, 0, (tr->n + 1) * sizeof(SPFLOAT));
    memset(tr->new_reflection, 0, (tr->n + 1) * sizeof(SPFLOAT));
    memset(tr->junction_outL, 0, (tr->n + 1) * sizeof(SPFLOAT));
    memset(tr->junction_outR, 0, (tr->n + 1) * sizeof(SPFLOAT));
    memset(tr->A, 0, tr->n * sizeof(SPFLOAT));
    memset(tr->max_amplitude, 0, tr->n * sizeof(SPFLOAT));
    memset(tr->noseL, 0, tr->nose_length * sizeof(SPFLOAT));
    memset(tr->noseR, 0, tr->nose_length * sizeof(SPFLOAT));
    memset(tr->nose_junc_outL, 0, (tr->nose_length + 1) * sizeof(SPFLOAT));
    memset(tr->nose_junc_outR, 0, (tr->nose_length + 1) * sizeof(SPFLOAT));
    memset(tr->nose_diameter, 0, tr->nose_length * sizeof(SPFLOAT));
    memset(tr->noseA, 0, tr->nose_length * sizeof(SPFLOAT));
    memset(tr->nose_max_amp, 0, tr->nose_length * sizeof(SPFLOAT));

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

    tr->nose_diameter[0] = tr->velum_target;
    tract_calculate_reflections(tr);
    tract_calculate_nose_reflections(tr);
}

@ 
@<Vocal Tract Computation...@>=
static SPFLOAT tract_compute(sp_data *sp, tract *tr, SPFLOAT in)
{
    return 0;
}

@
@<Calculate Vocal Tract Reflections @>=
static void tract_calculate_reflections(tract *tr)
{
    int i;
    SPFLOAT sum;

    for(i = 0; i < tr->n; i++) {
        tr->A[i] = tr->diameter[i] * tr->diameter[i];
    }

    for(i = 1; i < tr->n; i++) {
        tr->reflection[i] = tr->new_reflection[i];
        if(tr->A[i] == 0) {
            tr->new_reflection[i] = 0.999; /* to prevent bad behavior if 0 */
        } else {
            tr->new_reflection[i] = 
                (tr->A[i - 1] - tr->A[i]) / (tr->A[i - 1] + tr->A[i]);
        }
    }

    tr->reflection_left = tr->new_reflection_left;
    tr->reflection_right = tr->new_reflection_right;
    tr->reflection_nose = tr->new_reflection_nose;

    sum = tr->A[tr->nose_start] + tr->A[tr->nose_start + 1] + tr->noseA[0];
    tr->new_reflection_left = (2 * tr->A[tr->nose_start] - sum) / sum;
    tr->new_reflection_right = (2 * tr->A[tr->nose_start + 1] - sum) / sum;
    tr->new_reflection_nose = (2 * tr->noseA[0] - sum) / sum;
}

@
@<Calculate Vocal Tract Nose Reflections @>=
static void tract_calculate_nose_reflections(tract *tr)
{
    int i;

    for(i = 0; i < tr->nose_length; i++) {
        tr->noseA[i] = tr->nose_diameter[i] * tr->nose_diameter[i];
    }

    for(i = 1; i < tr->nose_length; i++) {
        tr->nose_reflection[i] = (tr->noseA[i - 1] - tr->noseA[i]) /
            (tr->noseA[i-1] + tr->noseA[i]);
    }
}
