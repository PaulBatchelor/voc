@* The Vocal Tract.
The vocal tract is the part of the vocal model which takes the
excitation signal (the glottis) and creates the sentation of vowels.

The two main functions for the vocal tract consist of of an initialization
function |tract_init| called once before runtime, and a computation
function |tract_compute| called at twice the sampling rate. See 
|@<Vocal Tract Init...@>| and |@<Vocal Tract Computation...@>| for more 
detail.

@<The Vocal Tract@>=
@<Calculate Vocal Tract Reflections @>@/
@<Calculate Vocal Tract Nose Reflections @>@/
@<Reshape Vocal Tract @>@/
@<Vocal Tract Init...@>@/
@<Vocal Tract Computation...@>@/

@ The function |tract_init| is responsible for zeroing out variables
and buffers, as well as setting up constants. 

@<Vocal Tract Initialization@>=
static void tract_init(sp_data *sp, tract *tr)
{
    int i;
    SPFLOAT diameter, d; /* needed to set up diameter arrays */@/
    @<Initialize Tract Constants and Variables@>@/
    @<Zero Out Tr...@>@/
    @<Set up Vocal Tract Diameters@>@/
    @<Set up Nose Diameters@>@/

    tract_calculate_reflections(tr);
    tract_calculate_nose_reflections(tr);
    tr->nose_diameter[0] = tr->velum_target;

    tr->block_time = 512.0 / (SPFLOAT)sp->sr;
}

@ @<Initialize Tract Constants and Variables@>=
tr->n = 44;
tr->nose_length = 28;
tr->nose_start = 17;

tr->reflection_left = 0.0;
tr->reflection_right = 0.0;
tr->reflection_nose = 0.0;
tr->new_reflection_left = 0.0;
tr->new_reflection_right= 0.0;
tr->new_reflection_nose = 0.0;
tr->velum_target = 0.01;
tr->glottal_reflection = 0.75;
tr->lip_reflection = -0.85;
tr->last_obstruction = -1;
tr->movement_speed = 15;
tr->lip_output = 0;
tr->nose_output = 0;
tr->tip_start = 32;

@ @<Zero Out Tract Buffers@>=
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

@ @<Set up Vocal Tract Diameters@>=
for(i = 0; i < tr->n; i++) {
    diameter = 0;
    if(i < 7 * (SPFLOAT)tr->n / 44 - 0.5) {
        diameter = 0.6;
    } else if( i < 12 * (SPFLOAT)tr->n / 44) {
        diameter = 1.1;
    } else {
        diameter = 1.5;
    }

    tr->diameter[i] = 
        tr->rest_diameter[i] = 
        tr->target_diameter[i] = 
        tr->new_diameter[i] = diameter;

}

@ @<Set up Nose Diameters@>=
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

@ The vocal tract computation function computes a single sample of audio.
As the original implementation describes it, this function is designed
to run at twice the sampling rate. For this reason, it is called twice 
in the top level call back (see |@<Voc Create@>|). 

At the moment, |tract_compute| has two input arguments. The variable |in|
is the glottal excitation signal. The |lambda| variable is a coefficient
for a linear crossfade along the buffer block, used for parameter smoothing.
In future iterations, the linear crossfade will be removed in place of one-pole 
smoothing filters. 
@<Vocal Tract Computation...@>=
static void tract_compute(sp_data *sp, tract *tr, 
    SPFLOAT @, in, 
    SPFLOAT @, lambda)
{
    SPFLOAT r, w;
    int i;

    tr->junction_outR[0] = tr->L[0] * tr->glottal_reflection + in;
    tr->junction_outL[tr->n] = tr->R[tr->n - 1] * tr->lip_reflection;

    for(i = 1; i < tr->n; i++) {
        r = tr->reflection[i] * (1 - lambda) + tr->new_reflection[i] * lambda;
        w = r * (tr->R[i - 1] + tr->L[i]);
        tr->junction_outR[i] = tr->R[i - 1] - w;
        tr->junction_outL[i] = tr->L[i] + w;
    }

    i = tr->nose_start;
    r = tr->new_reflection_left * (1-lambda) + tr->reflection_left*lambda;
    tr->junction_outL[i] = r*tr->R[i-1] + (1+r)*(tr->noseL[0]+tr->L[i]);
    r = tr->new_reflection_right * (1 - lambda) + tr->reflection_right * lambda;
    tr->junction_outR[i] = r*tr->L[i] + (1+r)*(tr->R[i-1]+tr->noseL[0]);
    r = tr->new_reflection_nose * (1 - lambda) + tr->reflection_nose * lambda;
    tr->nose_junc_outR[0] = r * tr->noseL[0]+(1+r)*(tr->L[i]+tr->R[i-1]);

    for(i = 0; i < tr->n; i++) {
        tr->R[i] = tr->junction_outR[i]*0.999;
        tr->L[i] = tr->junction_outL[i + 1]*0.999;
    }

    tr->lip_output = tr->R[tr->n - 1];

    tr->nose_junc_outL[tr->nose_length] = 
        tr->noseR[tr->nose_length-1] * tr->lip_reflection;

    for(i = 1; i < tr->nose_length; i++) {
        w = tr->nose_reflection[i] * (tr->noseR[i-1] + tr->noseL[i]);
        tr->nose_junc_outR[i] = tr->noseR[i - 1] - w;
        tr->nose_junc_outL[i] = tr->noseL[i] + w;
    }

    for(i = 0; i < tr->nose_length; i++) {
        tr->noseR[i] = tr->nose_junc_outR[i];
        tr->noseL[i] = tr->nose_junc_outL[i + 1];
    }

    tr->nose_output = tr->noseR[tr->nose_length - 1];

}

@ The function |tract_calculate_reflections| computes reflection 
coefficients used in the scattering junction. Because this is a rather
computationally expensive function, it is called once per render block,
and then smoothed. 

First, the cylindrical areas of tract section are computed by squaring 
the diameters, they are stored in the struct variable |A|. 

Using the areas calculated, the reflections are calculated using the following
formula:

$$R_i = {A_{i - 1} - A_{i} \over A_{i - 1} + A_i} $$

To prevent some divide-by-zero edge cases, when $A_i$ is exactly zero, it
is set to be $0.999$.

From there, the new coefficients are set. %TODO: elaborate

% TODO: The following eqn above will be derived by Julius. would be nice to 
% have!
@<Calculate Vocal Tract Reflections @>=
static void tract_calculate_reflections(tract *tr)
{
    int i;
    SPFLOAT @, sum; @/

    for(i = 0; i < tr->n; i++) {
        tr->A[i] = tr->diameter[i] * tr->diameter[i]; 
        /* Calculate area from diameter squared*/
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
    tr->new_reflection_left = (SPFLOAT)(2 * tr->A[tr->nose_start] - sum) / sum;
    tr->new_reflection_right = (SPFLOAT)(2 * tr->A[tr->nose_start + 1] - sum) / sum;
    tr->new_reflection_nose = (SPFLOAT)(2 * tr->noseA[0] - sum) / sum;
}

@ Similar to |tract_calculate_reflections|, this function computes 
reflection coefficients for the nasal scattering junction. For more 
information on the math that is happening, see 
|@<Calculate Vocal Tract Reflections@>|.
% TODO: is "nasal scattering junction" the proper terminology?
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

@ 

@<Reshape Vocal Tract @>=

static SPFLOAT move_towards(SPFLOAT current, SPFLOAT target, 
        SPFLOAT amt_up, SPFLOAT amt_down)
{
    SPFLOAT tmp;
    if(current < target) {
        tmp = current + amt_up;
        return MIN(tmp, target);
    } else {
        tmp = current - amt_down;
        return MAX(tmp, target);
    }
    return 0.0;
}

static void tract_reshape(tract *tr)
{
    SPFLOAT amount;
    SPFLOAT slow_return;
    SPFLOAT diameter;
    SPFLOAT target_diameter;
    int i;
    @q int last_obstruction; @>

    @q last_obstruction = -1; @>
    amount = tr->block_time * tr->movement_speed;

    for(i = 0; i < tr->n; i++) {
        slow_return = 0;
        diameter = tr->diameter[i];
        target_diameter = tr->target_diameter[i];

        @q if(diameter <= 0) last_obstruction = i; @>

        if(i < tr->nose_start) slow_return = 0.6;
        else if(i >= tr->tip_start) slow_return = 1.0;
        else {
            slow_return = 
                0.6+0.4*(i - tr->nose_start)/(tr->tip_start - tr->nose_start);
        }

        tr->diameter[i] = move_towards(diameter, target_diameter, 
                slow_return * amount, 2 * amount);

    }

    tr->nose_diameter[0] = move_towards(tr->nose_diameter[0], tr->velum_target,
            amount * 0.25, amount * 0.1);
    tr->noseA[0] = tr->nose_diameter[0] * tr->nose_diameter[0];
}
