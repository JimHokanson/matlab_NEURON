TITLE SRB channel
:Schwarz and Eikhof model on rat nodes
:Based on asssuming a nodal area of of 50 um2

COMMENT
{
--

DESIGN FLOW


INPUT PARAMETERS
-------------------------
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
	SUFFIX srb
	USEION na READ nai, nao WRITE ina
	USEION k READ ki, ko WRITE ik
	NONSPECIFIC_CURRENT il, iks
	RANGE pnabar, gkbar, gksbar, gl, el, il, iks
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
	celsius (degC) : 20
	
	pnabar = 7.04e-3 (cm/s) :=> 3.52*10^-9 cm3*s^-1
	gkbar = 0.030 (S/cm2) :15nS/50um2
	gksbar = 0.060 :30 nS/50um2
	gl = 60e-3 (mho/cm2) :30 nS /50um2
	
	nai (mM) : 35
	nao (mM) : 154
	ki (mM) : 155
	ko (mM) : 5.6

	el = -84 (mV)
	ek = -84 (mV)
	:CNodal = 1.4 pF 2.8 uF/cm^2 
	
	Vrest = -84 (mV)
	
	amA = 1.86
	amB = 65.6
	amC = 10.3
	ahA = 0.0336
	ahB = -27
	ahC = 11.0
	anA = 0.00798
	anB = -9.2
	anC = 1.10
	asA = 0.00122
	asB = 71.5
	asC = 23.6
	
	bmA = 0.0860
	bmB = 61.3
	bmC = 9.16
	bhA = 2.30
	bhB = 55.2
	bhC = 13.4
	bnA = 0.0142
	bnB = 8
	bnC = 10.5
	bsA = 0.000739
	bsB = 3.9
	bsC = 21.8
	
	Q10am = 2.2
	Q10bm = 2.2
	Q10ah = 2.9
	Q10bh = 2.9
	Q10an = 3
	Q10bn = 3
	Q10as = 3
	Q10bs = 3

	
	
}

:These are variables which are the unknowns in differential and algebraic equations. 
:They are normally the variables to be "SOLVE"ed for within the BREAKPOINT block.
:Membrane potential, v, is  never a state since only NEURON itself is allowed to calculate that value.

STATE {
	m h n s
}

:Variables that can be computed directly and that one might wish to know the value of during a simulation
:Divide these between range and global variables
ASSIGNED {
	ina (mA/cm2)
	ik (mA/cm2)
	il (mA/cm2)
	iks (mA/cm2)
	inf[4]
	tau[4] (ms)
}


INITIAL {
	:mhns sets inf and tau for the given membrane potential
	mhns(v*1(/mV))
	m = inf[0]
	h = inf[1]
	n = inf[2]
	s = inf[3]
}

BREAKPOINT {
	:MAIN COMPUTATION BLOCK
	:Solve directly calls the "states" derivative

	SOLVE states METHOD cnexp
	ina = pnabar*m*m*m*h*ghk(v, nai, nao)
	ik = gkbar*n*n*n*n*(v - ek)
	iks = s*gksbar*(v - ek)
	il = gl*(v - el)
}

:This function takes in the 
:Notice that 

FUNCTION ghk(v(mV), ci(mM), co(mM)) (.001 coul/cm3) {
	:This is the goldman-hodgkin-Katz sp? constant field Equation
	:assume a single charge
	:EF2/RT*(NAo - Nai*exp(EF/RT))/(1 - exp(EF/RT))
	LOCAL z, eco, eci
	:LOCAL z, concratio
	z = (1e-3)*FARADAY*v/(R*(celsius+273.15))
	eco = co*efun(z)
	eci = ci*efun(-z)
	:concRatio = (co - ci*exp(z))/(1 - exp(z))
	ghk = (.001)*FARADAY*(eci-eco)
}

FUNCTION efun(z) {
	if(fabs(z) < 1e-6){
		efun = 1 - z/2
	}else{
		efun = z/(exp(z)-1)
	}
}

DERIVATIVE states {	: exact when v held constant
	mhns(v*1(/mV))
	m' = (inf[0] - m)/tau[0]
	h' = (inf[1] - h)/tau[1]
	n' = (inf[2] - n)/tau[2]
	s' = (inf[3] - s)/tau[3]
}

UNITSOFF
:This turns unit checking off, making the code more readable
:It is up to the user to make sure that the units are correct

FUNCTION alp(v(mV),i) { LOCAL k :rest = -78  order m,h,n,s
	:Called by the mhnp procedure
	v = v-Vrest
	
	:i = 0, m, 1 = h, 2 = n
	if (i==0) {
		k = Q10am^((celsius - 20)/10)
		alp = k*amA*vtrap(amB - v,amC)
	}else if (i==1){
		k = Q10ah^((celsius - 20)/10)
		alp = k*ahA*vtrap(v - ahB,ahC)
	}else if (i==2){
		k = Q10an^((celsius - 20)/10)
		alp = k*anA*vtrap(anB - v,anC)
	}else{
		k = Q10as^((celsius - 20)/10)
		alp = k*asA*vtrap(asB - v,asC)
	}	
}


FUNCTION bet(v,i) { LOCAL k :rest = -78  order m,h,n,s
	:See alp function comments
	v = v-Vrest
	
	:i = 0, m, 1 = h, 2 = n
	if (i==0) {
		k = Q10bm^((celsius - 20)/10)
		bet = k*bmA*vtrap(v - bmB,bmC)
	}else if (i==1){
		k = Q10bh^((celsius - 20)/10)
		bet = k*bhA/(1 + exp((bhB - v)/bhC))
	}else if(i == 2){
		k = Q10bn^((celsius - 20)/10)
		bet = k*bnA*vtrap(v - bnB,bnC)
	}else{
		k = Q10bs^((celsius - 20)/10)
		bet = k*bsA*vtrap(v - bsB,bsC)
	}
}

:Vtrap? :/
:Implement this?
FUNCTION vtrap(x,y) {
	if (fabs(x/y) < 1e-6) {
		vtrap = y*(1 - x/y/2)
	}else{
		vtrap = x/(exp(x/y) - 1)
	}
}


:Called by INITIAL -> Typically called for the setting of variables

PROCEDURE mhns(v) {LOCAL a, b :rest = -70
	:Not sure what this line does
	:TABLE variables DEPEND dependencies FROM lowest TO highest WITH tablesize
	:This somehow creates a speedup
	:dependencies -> causes recalculatio of the table
	:usetable_suffix = 0 -> in this case usetable_fh = 0 in the hoc code causes tables not to be used
	:the range is for the arguement, thus the vales are defined from -100 to 100 with 200 values total and interpolated inbetween
	
	
	TABLE inf, tau DEPEND celsius FROM -100 TO 100 WITH 200
	FROM i=0 TO 3 {
		a = alp(v,i)  
		b=bet(v,i)
		tau[i] = 1/(a + b)
		inf[i] = a/(a + b)
	}
}

UNITSON
