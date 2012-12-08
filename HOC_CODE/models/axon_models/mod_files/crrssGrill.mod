TITLE CRRSS channel
: Frankenhaeuser - Huxley channels for Xenopus

COMMENT
{
--

DESIGN FLOW


INPUT PARAMETERS
-------------------------
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
	SUFFIX crrssGrill
	:USEION na READ nai, nao WRITE ina
	USEION na WRITE ina
	:USEION k READ ki, ko WRITE ik
	NONSPECIFIC_CURRENT il
	RANGE gnabar, ena, gl, el
	GLOBAL inf, tau
	:made m & h global
	
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
	Vrest = -80 (mV)
    dt (ms)
	gnabar = 2.168 (mho/cm2):changes from 1.445
    ena = 64 (mV)			:changes from 35.64
    gl = 0.128 (mho/cm2)
    el = -80.01 (mV)
	amA  = 31.0 (mV)		:amA = -amA_Grill - Vrest = -49 - (-80)
	amB = 97.0 (1/ms)		:amB = amB_Grill + amC*Vrest = 126 + 0.363*(-80)
	amC = 0.363 (1/ms*mV)
	amD  = 5.3 (mV)
	bmA  = -23.8 (mV)		:bmA = bmA_Grill + Vrest = 56.2 + (-80)
	bmB = 4.17 (mV)
	ahA = 24.0 (mV)			:ahA = -ahA_Grill - Vrest = -56 - (-80)
	ahB = 15.6 (1/ms)
	bhA  = 10 (mV)
	bhB  = -5.5 (mV)		:bhB = bhB_Grill + Vrest = 74.5 + (-80)
	bhC  = 5.0 (mV)
	
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
	LOCAL drForNa
	:Solve directly calls the "states" derivative
	SOLVE states METHOD cnexp
	:drForNa = Nernst(v, nai, nao)
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
	:(v = Em - Vrest)
	:here the parameters have been modified appropriately
	:Q10 is 3 for all alphas and betas
	k = 3^((celsius - 37)/10) 
	am = (amB + amC*v)/(1+exp((amA-v)/amD))*k
	bm = am/(exp((v+bmA)/bmB))*k
	bh = ahB/(1+exp((ahA-v)/bhA))*k
	ah = bh/(exp((v+bhB)/bhC))*k
	
	
	
	:amB = 126 (1/ms)
	:amC = 0.363 (1/ms*mV)
	:amA  = 49 (mV)
	:amD  = 5.3 (mV)
	
	:BmA  = 56.2 (mV)
	:BmB = 4.17 (mV)
	
	
	
	:ahA = 56.0 (mV) 
	:ahB = 15.6 (1/ms)
	:BhA  = 10 (mV)
	:BhB  = 74.5 (mV)
	:BhC  = 5.0 (mV)
	
	
	
	
	
	
	
	tau[0] = 1/(am + bm)
	inf[0] = am/(am + bm)
	tau[1] = 1/(ah + bh)
	inf[1] = ah/(ah + bh)

	
	
	
	:Might make a new mod file that has all of these
	:as parameters
	
	:McIntyre & Grill 1998
	:show and given values are off by 80
	:
	
	:am = (amB + amC*v)/(1+exp(-(v+amA)/amD))
	:     97  0.363  		     -31   5.3
	:	 126  0.363    			49     5.3
	:						  31 - v - (80)
	:						  -49   - v - (x => -80) %if you add -80 you get
	:						the normal equation
	:	 difference comes in on amB from mult 0.363 with 
	:	 0.363*-80 => -29.04 => 126 - 29 = 97
	:
	:bm = am/(exp((v+bmA)/bmB))
	:                -23.8  4.17
	:				 56.2  4.17
	:
	:ah = bh/(exp((v+bhB)/bhC))
	:                -5.5  5
	:				 74.5  5
	:
	:bh = ahB/(1+exp(-(v+ahA)/bhA))
	:     15.6           -24  10
	:	  15.6			 56	  10
	:
	:    Default		Variation  Delta 10.2
	:amA 49    mV		39.2-73.5       59.2
	:amB 126   ms-1     63-189          136.2
	:amC 0.363 ms-1/mV  0.182-0.545     0.363
	:amD 5.3   mV       2.65-7.95       5.3
	:BmA 56.2  mV       28.1-61.8       66.4
	:BmB 4.17  mV		2.09-6.26		4.17	    
	:ahA 56.0  mV		28-84			66.2
	:ahB 15.6  ms-1		7.8-23.4		15.6
	:BhA 10.0  mV		5-15			10.0
	:BhB 74.5  mV		67.1-81.9		84.7
	:BhC 5.0   mV		2.5-7.5			5.0
}
UNITSON
