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
    glot->time_in_waveform = 0;
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

    out = 0;
    intensity = 1.0;
    glot->time_in_waveform += glot->T;

    if(glot->time_in_waveform > glot->waveform_length) {
        glot->time_in_waveform -= glot->waveform_length;
        glottis_setup_waveform(glot);

    }

    t = (glot->time_in_waveform / glot->waveform_length);
@q PT: normalizedLFWaveform @>
    if(t > glot->Te) {
        out = (-exp(-glot->epsilon * (t-glot->Te)) + glot->shift) / glot->delta;
    } else {
        out = glot->E0 * exp(glot->alpha * t) * sin(glot->omega * t);
    }

@q out = out * glot->intensity * glot->loudness @>

@q generate white noise source @>
    noise = 2.0 * ((SPFLOAT) sp_rand(sp) / SP_RANDMAX) - 1;

@q intensity set to 1.0 for now @>
    aspiration = intensity * (1 - sqrt(glot->tenseness)) * 0.3 * noise;

    aspiration *= 0.2;

    out += aspiration;

    return out;
}

@ The function |glottis_setup_waveform| is tasked with setting the variables
needed to create the glottis waveform. The glottal model used here is known
as the LF-model, as described in Lu and Smith\cite{lu2000glottal}.


@<Set up Glottis Waveform@>=
static void glottis_setup_waveform(glottis *glot)
{
    @<Set up local variables@>@/
    @<Derive |waveform_length|...@>@/
    @<Derive $R_a$, $R_k$, ...@>@/
    @<Derive $T_a$...@>@/

    @<Calculate epsilon, shift, and delta@>@/

    @<Calculate Integrals@>@/
    @<Calculate $E_0$@>@/

    @<Update variables in glot...@>
}

@ A number of local variables are used for intermediate
calculations. They are described below.
@<Set up local variables@>=
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

@ To begin, both |waveform_length| and $R_d$ are calcuated. 

The variable |waveform_length| is the period of the waveform based on the 
current frequency, and will be used later on in |@<Glottis Computation@>|. 

$R_d$ is part of a set of normalized timing parameters used to calculate
the time coefficients described in the LF model @q cite fant 1997 here@>. 
The other timing parameters $R_a$, $R_g$, and $R_k$ can
be computed in terms of $R_d$, which is why this gets computed first. 
$R_d$ is derived from the parameter |glot->tenseness|. 

$R_d$ is then clamped to be in between 0.5 and 2.7, as these
are good approximations\cite{lu2000glottal}.

@<Derive |waveform_length| and $R_d$@>=
glot->Rd = 3 * (1 - glot->tenseness);
glot->waveform_length = 1.0 / glot->freq;

Rd = glot->Rd;
if(Rd < 0.5) Rd = 0.5;
if(Rd > 2.7) Rd = 2.7;

@ $R_d$ can be used to calculate appriximations for $R_a$, $R_g$, and $R_k$. 
The equations described below have been derived using linear regression. 
$$R_{ap} = (-1 + 4.8R_d)/100$$
$$R_{kp} = (22.4 + 11.8R_d)/100$$

$R_{gp}$ is derived using the results from $R_{ap}$ and $R_{kp}$ in 
the following equation described in Fant 1997:

$$R_d = (1/0.11)(0.5 + 1.2R_{k})(R_k / 4R_g + R_a)$$

Which yields:
% TODO: extract \frac from eplain
% TODO: work out this algebraic equation
$$R_{gp} = (R_{kp}/4)(0.5 + 1.2R_{kp})/(0.11R_d - R_{ap}*(0.5+1.2R_{kp}))$$

@<Derive $R_a$, $R_k$, and $R_g$@>=
Ra = -0.01 + 0.048*Rd; 
Rk = 0.224 + 0.118*Rd;
Rg = (Rk/4)*(0.5 + 1.2*Rk)/(0.11*Rd-Ra*(0.5+1.2*Rk));

@ The parameters approximating $R_a$, $R_g$, and $R_k$ can be used to 
calculate the timing parameters $T_a$, $T_p$, and $T_e$ in the LF model:

$$T_a = R_{ap}$$ 
$$T_p = 2R_{gp}^{-1}$$ 
$$T_e = T_p + T_pR_{kp}$$

@<Derive $T_a$, $T_p$, and $T_e$@>=
Ta = Ra;
Tp = (SPFLOAT)1.0 / (2*Rg);
Te = Tp + Tp*Rk;

@ @<Calculate epsilon, shift, and delta@>=
epsilon = (SPFLOAT)1.0 / Ta;
shift = exp(-epsilon * (1 - Te));
delta = 1 - shift;

@ @<Calculate Integrals@>=
rhs_integral = (SPFLOAT)(1.0/epsilon) * (shift-1) + (1-Te)*shift;
rhs_integral = rhs_integral / delta;
lower_integral = - (Te - Tp) / 2 + rhs_integral;
upper_integral = -lower_integral;

@ @<Calculate $E_0$@>=
omega = M_PI / Tp;
s = sin(omega * Te);

y = -M_PI * s * upper_integral / (Tp*2);
z = log(y);
alpha = z / (Tp/2 - Te);
E0 = -1 / (s * exp(alpha*Te));

@ @<Update variables in glottis data structure@>=
glot->alpha = alpha;
glot->E0 = E0;
glot->epsilon = epsilon;
glot->shift = shift;
glot->delta = delta;
glot->Te = Te;
glot->omega = omega;
