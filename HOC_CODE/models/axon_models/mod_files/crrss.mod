TITLE CRRSS channel
: Frankenhaeuser - Huxley channels for Xenopus

COMMENT
{
--

DESIGN FLOW


INPUT PARAMETERS
-------------------------------------
- need to specifiy celsius, and maybe ena and el, not sure

nai=13.74  nao=114.5  ki=120 ko=2.5
{celsius=20  secondorder=2 dt=.025}




NEURON -> need to be set
PARAMETER
STATE
ASSIGNED 

THEN
INITIAL -> set state variables to some value, probably their value at inf
-> use procedure that calls alpha and beta, then defines taus and inf, use table function

BREAKPOINT
- calls appropriate derivative
  - derivative updates the alphas and betas, and the taus and inf, then updates the derivative values
- sets the current equations using the states



suffix fh -> used with insert

outward total current carried by this ion, iion; internal and external concentrations 
of this ion, ioni and iono; and reversal potential of this ion, eion

USEION ionname Read Parameters WRITE

NONSPECIFIC_CURRENT -> what does this do?

FUNCTION's written in a model are global and may be used in other models if they do not involve range variables.
It is extremely important that mechanisms have consistent units. To ensure this use the modlunit exexcutable

BASIC NMODEL COMPONENTS
http://www.neuron.yale.edu/neuron/docs/help/neuron/nmodl/nmodl.html#BasicNMODLStatements

--
}
ENDCOMMENT


NEURON {    
	SUFFIX crrss
	:USEION na READ nai, nao WRITE ina
	USEION na WRITE ina
	:USEION k READ ki, ko WRITE ik
	NONSPECIFIC_CURRENT il
	RANGE gnabar, ena, gl, el
	GLOBAL inf,tau
}


:The Include statement replaces itself with the contents of the file
:I'm not sure why this is needed, probably best to include on all models

INCLUDE "standard.inc"

COMMENT
{
--
Special variables to NEURON such as celsius, area, v, etc. if used in a model should be declared as parameters
These are variables which are set by the user and not changed by the model itself

%Can they be changed by the user in a model if they wanted to from the default?
--
}
ENDCOMMENT



PARAMETER {
	v (mV)
	celsius = 37 (degC)
    dt (ms)
	gnabar = 1.445 (mho/cm2)
    ena = 35 (mV)
    gl = 0.128 (mho/cm2)
    el = -80.01 (mV)
	Vrest = -80 (mV)
}

:These are variables which are the unknowns in differential and algebraic equations. 
:They are normally the variables to be "SOLVE"ed for within the BREAKPOINT block.
:Membrane potential, v, is  never a state since only NEURON itself is allowed to calculate that value.

STATE {
	m h
}

:Variables that can be computed directly and that one might wish to know the value of during a simulation
:Divide these between range and global variables
ASSIGNED {
	ina (mA/cm2)
	il (mA/cm2)
	inf[2]
	tau[2] (ms)
}

:I'm not sure what the purpose of the mhnp(v*1(/mV)) does


:states can be initialized by the user at the hoc level

INITIAL {
	:mhnp sets inf and tau for the given membrane potential
	mh(v*1(/mV))
	m = inf[0]
	h = inf[1]
}

BREAKPOINT {
	:MAIN COMPUTATION BLOCK
	:Solve directly calls the "states" derivative
	SOLVE states METHOD cnexp

	ina = gnabar*m*m*h*(v - ena)
	il = gl*(v - el)
}

:This function takes in the 
:Notice that 

COMMENT {
--
FUNCTION Nernst(v(mV), ci(mM), co(mM)) (.001 coul/cm3) {Local rtOverF
	:assume a single charge
	:Nernst = RT/nF*ln(out/in)
	rtOverF = (R*(celsius+273.15))/FARADAY
	Nernst = rtOverF*log(co/ci)
}
-- }
ENDCOMMENT

DERIVATIVE states {	: exact when v held constant
	mh(v*1(/mV))
	m' = (inf[0] - m)/tau[0]
	h' = (inf[1] - h)/tau[1]
}

UNITSOFF
:This turns unit checking off, making the code more readable
:It is up to the user to make sure that the units are correct

:Called by INITIAL -> Typically called for the setting of variables

PROCEDURE mh(v) {LOCAL am, bm, ah, bh, k :rest = -80
	:Not sure what this line does
	:TABLE variables DEPEND dependencies FROM lowest TO highest WITH tablesize
	:This somehow creates a speedup
	:dependencies -> causes recalculatio of the table
	:usetable_suffix = 0 -> in this case usetable_fh = 0 in the hoc code causes tables not to be used
	:the range is for the arguement, thus the vales are defined from -100 to 100 with 200 values total and interpolated inbetween
	TABLE inf, tau DEPEND celsius FROM -100 TO 100 WITH 200
	
	v = v - Vrest
	:Q10 is 3 for all alphas and betas
	k = 3^((celsius - 37)/10) 
	
	am = (97 + 0.363*v)/(1 + exp((31 - v)/5.3))*k
	bm = am/exp((v - 23.8)/4.17)*k
	ah = bh/exp((v - 5.5)/5)*k
	bh = 15.6/(1 + exp((24 - v)/10))*k
	
	tau[0] = 1/(am + bm)
	inf[0] = am/(am + bm)
	tau[1] = 1/(ah + bh)
	inf[1] = ah/(ah + bh)

}
UNITSON
