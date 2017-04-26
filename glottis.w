@* The Glottis.

This is where the synthesis of the glottal source signal will be created. 

While the implementation comes directly from Pink Trombone's JavaScript code, 
it should be noted that the glottal model is based on a modified 
LF-model\cite{lu2000glottal}.

@<The Glottis@>=
@<Set up Glottis Waveform@>@\
@<Glottis Initialization@>@\
@<Glottis Computation@>@\

@ Initializiation of the glottis is done inside of |glottis_init|. 

@<Glottis Initialization@>=
static void glottis_init(glottis *glot, SPFLOAT sr)
{
    glot->freq = 140; /* 140Hz frequency by default */
    glot->tenseness = 0.6; /* value between 0 and 1 */
    glot->T = 1.0/sr; /* big T */
    glottis_setup_waveform(glot);
}

@ This is where a single sample of audio is computed for the glottis

% TODO: implement intensity and loudness, if needed
% out = out * glot->intensity * glot->loudness;

@<Glottis Computation@>=
static SPFLOAT glottis_compute(sp_data *sp, glottis *glot)
{
    SPFLOAT out;
    SPFLOAT aspiration;
    SPFLOAT noise;
    SPFLOAT t;
    SPFLOAT intensity;

    intensity = 1.0;
    glot->time_in_waveform += glot->T;

    if(glot->time_in_waveform > glot->waveform_length) {
        glot->time_in_waveform -= glot->waveform_length;
        glottis_setup_waveform(glot);

    }

    t = (glot->time_in_waveform / glot->waveform_length);

    if(t > glot->Te) {
        out = (-exp(-glot->epsilon * (t-glot->Te)) + glot->shift) / glot->delta;
    } else {
        out = glot->E0 * exp(glot->alpha * t) * sin(glot->omega * t);
    }

    noise = 2.0 * ((SPFLOAT) sp_rand(sp) / SP_RANDMAX) - 1;

    aspiration = intensity * (1 - sqrt(glot->tenseness)) * 0.3 * noise;

    aspiration *= 0.2;

    out += aspiration;

    return out;
}

@ The function |glottis_setup_waveform| is tasked with creating the
glottis waveform.
@<Set up Glottis Waveform@>=
static void glottis_setup_waveform(glottis *glot)
{
    SPFLOAT Rd;
    SPFLOAT Ra;
    SPFLOAT Rk;
    SPFLOAT Rg;

    SPFLOAT Ta;
    SPFLOAT Tp;
    SPFLOAT Te;

    SPFLOAT epsilon;
    SPFLOAT shift;
    SPFLOAT delta;
    SPFLOAT rhs_integral;

    SPFLOAT lower_integral;
    SPFLOAT upper_integral;

    SPFLOAT omega;
    SPFLOAT s;
    SPFLOAT y;
    SPFLOAT z;

    SPFLOAT alpha;
    SPFLOAT E0;

    glot->Rd = 3 * (1 - glot->tenseness);
    glot->waveform_length = 1.0 / glot->freq;

    Rd = glot->Rd;
    if(Rd < 0.5) Rd = 0.5;
    if(Rd > 2.7) Rd = 2.7;

    Ra = -0.01 + 0.048*Rd;
    Rk = 0.224 + 0.118*Rd;
    Rg = (Rk/4)*(0.5 + 1.2*Rk)/(0.11*Rd-Ra*(0.5+1.2*Rk));

    Ta = Ra;
    Tp = 1 / (2*Rg);
    Te = Tp + Tp*Rk;

    epsilon = 1 / Ta;

    shift = exp(-epsilon * (1 - Te));
    delta = 1 - shift;

    rhs_integral = (1/epsilon) * (shift-1) + (1-Te)*shift;
    rhs_integral = rhs_integral / delta;

    lower_integral = (Te - Tp) * 0.5 + rhs_integral;
    upper_integral = -lower_integral;

    omega = M_PI / Tp;
    s = sin(omega * Te);

    y = -M_PI * s * upper_integral / (Tp*2);
    z = log(y);
    alpha = z / (Tp/2 - Te);
    E0 = -1 / (s * exp(alpha*Te));

    glot->alpha = alpha;
    glot->E0 = E0;
    glot->epsilon = 0;
    glot->shift = shift;
    glot->delta = delta;
    glot->Te = Te;
    glot->omega = omega;
}

