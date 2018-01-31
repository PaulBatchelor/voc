@* The Vocal Tract.
The vocal tract is the part of the vocal model which takes the
excitation signal (the glottis) and produces the vowel formants from it.

The two main functions for the vocal tract consist of of an initialization
function |tract_init| called once before runtime, and a computation
function |tract_compute| called at twice the sampling rate. See 
|@<Vocal Tract Init...@>| and |@<Vocal Tract Computation...@>| for more 
detail.

@<The Vocal Tract@>=
@<Calculate Vocal Tract Reflections @>@/
@<Calculate Vocal Tract Nose Reflections @>@/
@<Vocal Tract Transients@>@/
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
    tr->T = 1.0 / (SPFLOAT)sp->sr;
    @<Initialize Transient Pool@>
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

@ Several floating-point arrays are needed for the scattering junctions. 
C does not zero these out by default. Below, the standard function 
|memset()| from |string.h| is used to zero out each of the blocks of memory. 
@<Zero Out Tract Buffers@>=
memset(tr->diameter, 0, tr->n * sizeof(SPFLOAT));
memset(tr->rest_diameter, 0, tr->n * sizeof(SPFLOAT));
memset(tr->target_diameter, 0, tr->n * sizeof(SPFLOAT));
memset(tr->L, 0, tr->n * sizeof(SPFLOAT));
memset(tr->R, 0, tr->n * sizeof(SPFLOAT));
memset(tr->reflection, 0, (tr->n + 1) * sizeof(SPFLOAT));
memset(tr->new_reflection, 0, (tr->n + 1) * sizeof(SPFLOAT));
memset(tr->junction_outL, 0, (tr->n + 1) * sizeof(SPFLOAT));
memset(tr->junction_outR, 0, (tr->n + 1) * sizeof(SPFLOAT));
memset(tr->A, 0, tr->n * sizeof(SPFLOAT));
memset(tr->noseL, 0, tr->nose_length * sizeof(SPFLOAT));
memset(tr->noseR, 0, tr->nose_length * sizeof(SPFLOAT));
memset(tr->nose_junc_outL, 0, (tr->nose_length + 1) * sizeof(SPFLOAT));
memset(tr->nose_junc_outR, 0, (tr->nose_length + 1) * sizeof(SPFLOAT));
memset(tr->nose_diameter, 0, tr->nose_length * sizeof(SPFLOAT));
memset(tr->noseA, 0, tr->nose_length * sizeof(SPFLOAT));

@ The cylindrical diameters approximating the vocal tract are set up
below. These diameters will be modified and shaped by user control to
shape the vowel sound.

The initial shape of the vocal tract is plotted below:

\displayfig{plots/tract.eps}

@<Set up Vocal Tract Diameters@>=
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
        tr->target_diameter[i] = diameter;

}

@ The cylindrical diameters representing nose are set up. These are only
set once, and are immutable for the rest of the program.

The shape of the nasal passage is plotted below:

\displayfig{plots/nose.eps}

% TODO: use gnuplot to generate picture of what it looks like
@<Set up Nose Diameters@>=
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

|tract_compute| has two input arguments. The variable |in|
is the glottal excitation signal. The |lambda| variable is a coefficient
for a linear crossfade along the buffer block, used for parameter smoothing.
@<Vocal Tract Computation...@>=
static void tract_compute(sp_data *sp, tract *tr, 
    SPFLOAT @, in, 
    SPFLOAT @, lambda)
{
    @/ SPFLOAT @, r, w;
    int i;
    SPFLOAT @, amp;
    int current_size;
    transient_pool *pool;
    transient *n;

    @/
    @<Process Transients@>@/
    @<Calculate Scattering Junctions@>@/
    @<Calculate Scattering for Nose...@>@/
    @<Update Left/Right delay lines...@>@/
    @<Calculate Nose Scattering Junctions@>@/
    @<Update Nose Left/Right delay lines...@>@/
}

@ A derivation of $w$ can be seen in section 2.5.2 of Jack Mullens 
PhD dissertation {\it Physical Modelling of the Vocal Tract 
with the 2D Digital Waveguide Mesh}.
\cite{mullen2006physical}
@<Calculate Scattering Junctions@>=
tr->junction_outR[0] = tr->L[0] * tr->glottal_reflection + in;
tr->junction_outL[tr->n] = tr->R[tr->n - 1] * tr->lip_reflection;

for(i = 1; i < tr->n; i++) {
    r = tr->reflection[i] * (1 - lambda) + tr->new_reflection[i] * lambda;
    w = r * (tr->R[i - 1] + tr->L[i]);
    tr->junction_outR[i] = tr->R[i - 1] - w;
    tr->junction_outL[i] = tr->L[i] + w;
}

@ @<Calculate Scattering for Nose@>=
i = tr->nose_start;
r = tr->new_reflection_left * (1-lambda) + tr->reflection_left*lambda;
tr->junction_outL[i] = r*tr->R[i-1] + (1+r)*(tr->noseL[0]+tr->L[i]);
r = tr->new_reflection_right * (1 - lambda) + tr->reflection_right * lambda;
tr->junction_outR[i] = r*tr->L[i] + (1+r)*(tr->R[i-1]+tr->noseL[0]);
r = tr->new_reflection_nose * (1 - lambda) + tr->reflection_nose * lambda;
tr->nose_junc_outR[0] = r * tr->noseL[0]+(1+r)*(tr->L[i]+tr->R[i-1]);

@ @<Update Left/Right delay lines and set lip output@>=
for(i = 0; i < tr->n; i++) {
    tr->R[i] = tr->junction_outR[i]*0.999;
    tr->L[i] = tr->junction_outL[i + 1]*0.999;
}
tr->lip_output = tr->R[tr->n - 1];

@ @<Calculate Nose Scattering Junctions@>=
tr->nose_junc_outL[tr->nose_length] = 
    tr->noseR[tr->nose_length-1] * tr->lip_reflection;

for(i = 1; i < tr->nose_length; i++) {
    w = tr->nose_reflection[i] * (tr->noseR[i-1] + tr->noseL[i]);
    tr->nose_junc_outR[i] = tr->noseR[i - 1] - w;
    tr->nose_junc_outL[i] = tr->noseL[i] + w;
}

@ @<Update Nose Left/Right delay lines and set nose output@>=
for(i = 0; i < tr->nose_length; i++) {
    tr->noseR[i] = tr->nose_junc_outR[i];
    tr->noseL[i] = tr->nose_junc_outL[i + 1];
}
tr->nose_output = tr->noseR[tr->nose_length - 1];

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

@ %TODO: Explain these functions. 

@<Reshape Vocal Tract @>=

static void tract_reshape(tract *tr)
{
    SPFLOAT amount;
    SPFLOAT slow_return;
    SPFLOAT diameter;
    SPFLOAT target_diameter;
    int i;
    int current_obstruction;

    current_obstruction = -1; 
    amount = tr->block_time * tr->movement_speed;

    for(i = 0; i < tr->n; i++) {
        slow_return = 0;
        diameter = tr->diameter[i];
        target_diameter = tr->target_diameter[i];

        if(diameter < 0.001) current_obstruction = i;

        if(i < tr->nose_start) slow_return = 0.6;
        else if(i >= tr->tip_start) slow_return = 1.0;
        else {
            slow_return = 
                0.6+0.4*(i - tr->nose_start)/(tr->tip_start - tr->nose_start);
        }

        tr->diameter[i] = move_towards(diameter, target_diameter, 
                slow_return * amount, 2 * amount);

    }

    if(tr->last_obstruction > -1 && current_obstruction == -1 && 
            tr->noseA[0] < 0.05) {
        append_transient(&tr->tpool, tr->last_obstruction);
    }
    tr->last_obstruction = current_obstruction;

    tr->nose_diameter[0] = move_towards(tr->nose_diameter[0], tr->velum_target,
            amount * 0.25, amount * 0.1);
    tr->noseA[0] = tr->nose_diameter[0] * tr->nose_diameter[0];
}

@ In Pink Trombone, there is a special handling of diameters that are exactly
zero. From a physical point of view, air is completly blocked, and this 
obstruction of air produces a transient "click" sound. To simulate this, 
any obstructions are noted during the reshaping of the vocal tract 
(see |@<Reshape...@>|), and the latest obstruction position is noted and pushed
onto a stack of transients. During the vocal tract computation, the exponential
damping contributes to the overal amplitude of the left-going and right-going
delay lines at that precise diameter location. This can be seen in the section
|@<Process Transients@>|.

% TODO: Wouldn't it be nice to have a plot of what the transient looks like?

@<Vocal Tract Transients@>=
@<Append Transient@>@/
@<Remove Transient@>@/

@ The transient pool is initialized inside along with the entire vocal tract
inside of |@<Vocal Tract Initialization@>|. It essentially sets the pool
to a size of zero and that the first available free transient is at index "0".

The transients in the pool will all have their boolean variable |is_free|,
set to be true so that they can be in line to be selected. 

To remove any valgrind issues related to unitialized variables, {\it all}
the members in the |transient| data struct are set to some parameter.

@<Initialize Transient Pool@>=
tr->tpool.size = 0;
tr->tpool.next_free = 0;
for(i = 0; i < MAX_TRANSIENTS; i++) {
    tr->tpool.pool[i].is_free = 1;
    tr->tpool.pool[i].id = i;
    tr->tpool.pool[i].position = 0;
    tr->tpool.pool[i].time_alive = 0;
    tr->tpool.pool[i].strength = 0;
    tr->tpool.pool[i].exponent = 0;
}

@ Any obstructions noted during |@<Reshape...@>| must be appended to the list 
of previous transients. 
The function will return a 0 on failure, and a 1 on success.

Here is an overview of how a transient may get appended:
\item{0.} Check and see if the pool is full. If this is so, return 0.
\item{1.} If there is no recorded next free (the id is -1), search for 
one using brute force and check for any free transients. If none can be
found, return 0. Since |MAX_TRANSIENTS| is a low N, even the worst-case 
searches do not pose a significant performance penalty. 
\item{2.} With a transient found, assign the current root of the list to be
the next value in the transient. (It does not matter if the root is NULL, 
because the size of the list will prevent it from ever being accessed.)
\item{3.} Increase the size of the pool by 1.
\item{4.} Toggle the |is_free| boolean of the current transient to be false.
\item{5.} Set the |position|.
\item{6.} Set the |time_alive| to be zero seconds.
\item{7.} Set the |lifetime| to be 200ms, or 0.2 seconds.
\item{8.} Set the |strength| to an amplitude 0.3. 
\item{9.} Set the |exponent| parameter to be 200.
\item{10.} Set the |next_free| parameter to be $-1$.

@<Append Transient@>=
static int append_transient(transient_pool *pool, int position)
{
    int i;
    int free_id;
    transient *t;

    free_id = pool->next_free;
    if(pool->size == MAX_TRANSIENTS) return 0;

    if(free_id == -1) {
        for(i = 0; i < MAX_TRANSIENTS; i++) {
            if(pool->pool[i].is_free) {
                free_id = i;
                break;
            }
        }
    }

    if(free_id == -1) return 0;

    t = &pool->pool[free_id];
    t->next = pool->root;
    pool->root = t;
    pool->size++;
    t->is_free = 0;
    t->time_alive = 0;
    t->lifetime = 0.2;
    t->strength = 0.3;
    t->exponent = 200;
    t->position = position;
    pool->next_free = -1;
    return 0;
}

@ When a transient has lived it's lifetime, it must be removed from the list of
transients. To keep things sane, transients have a unique ID for identification.
This is preferred to comparing pointer addresses. While more efficient, this
method is prone to subtle implementation errors. 

The method for removing a transient from a linked list is fairly typical:

\item{0.} If the transient *is* the root, set the root to be the next value. 
Decrease the size by one, and return.
\item{1.} Iterate through the list and search for the entry. 
\item{2.} Once the entry has been found, decrease the pool size by 1. 
\item{3.} The transient, now free for reuse, can now be toggled to be free,
and it can be the next variable ready to be used again. 
@<Remove Transient@>=

static void remove_transient(transient_pool *pool, unsigned int id)
{
    int i;
    transient *n;

    pool->next_free = id;
    n = pool->root;
    if(id == n->id) {
        pool->root = n->next;
        pool->size--;
        return;
    }

    for(i = 0; i < pool->size; i++) {
        if(n->next->id == id) {
            pool->size--;
            n->next->is_free = 1;
            n->next = n->next->next;
            break;
        }
        n = n->next;
    }
}

@ Transients are processed during |@<Vocal Tract Computation@>|. The transient
list is iterated through, their contributions are made to the Left and Right 
delay lines. 

In this implementation, the transients in the list are iterated through, and
their contributions are calculated using the following exponential function:

$$A = s2^{-E_0 * t}$$

Where:
\item{$\bullet$} $A$ is the contributing amplitude to the left and right-going
components.
\item{$\bullet$} $s$ is the overall strength of the transient.
\item{$\bullet$} $E_0$ is the exponent variable constant.
\item{$\bullet$} $t$ is the time alive. 

This particular function also must check for any transients that need to
be removed, and removes them. Some caution must be made to make sure that
this is done properly. Because a call to |remove_transient| changes the 
size of the pool, a copy of the current size is copied to a variable for the 
for loop.
Since the list iterates in order, it is presumably 
safe to remove values from the list while the list is iterating.


@<Process Transients@>=
    pool = &tr->tpool;
    current_size = pool->size;
    n = pool->root;
    for(i = 0; i < current_size; i++) {
        amp = n->strength * pow(2, -1.0 * n->exponent * n->time_alive);
        tr->L[n->position] += amp * 0.5;
        tr->R[n->position] += amp * 0.5;
        n->time_alive += tr->T * 0.5;
        if(n->time_alive > n->lifetime) {
             remove_transient(pool, n->id);
        }
        n = n->next;
    }
