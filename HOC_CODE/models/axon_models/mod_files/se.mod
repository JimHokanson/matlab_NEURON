TITLE SE channel
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
	SUFFIX se
	USEION na READ nai, nao WRITE ina
	USEION k READ ki, ko WRITE ik
	NONSPECIFIC_CURRENT il 
	RANGE pnabar, pkbar, gl, el, il
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
	celsius (degC) : 37
	
	pnabar=3.28e-3 (cm/s)
	pkbar=1.34e-4 (cm/s)
	
	nai (mM) : 8.71
	nao (mM) : 154
	ki (mM) : 155
	ko (mM) : 5.9
	gl = 86e-3 (mho/cm2)
	el = -78 (mV)
	
	Vrest = -78 (mV)
	
	amA = 1.87
	amB = 25.41
	amC = 6.06
	ahA = 0.55
	ahB = -27.74
	ahC = 9.06
	anA = 0.13
	anB = 35
	anC = 10
	
	bmA = 3.97
	bmB = 21
	bmC = 9.41
	bhA = 22.6
	bhB = 56
	bhC = 12.5
	bnA = 0.32
	bnB = 10
	bnC = 10
	
	Q10am = 2.2
	Q10bm = 2.2
	Q10an = 3
	Q10bn = 3
	Q10ah = 2.9
	Q10bh = 2.9

	
	
}

:These are variables which are the unknowns in differential and algebraic equations. 
:They are normally the variables to be "SOLVE"ed for within the BREAKPOINT block.
:Membrane potential, v, is  never a state since only NEURON itself is allowed to calculate that value.

STATE {
	m h n
}

:Variables that can be computed directly and that one might wish to know the value of during a simulation
:Divide these between range and global variables
ASSIGNED {
	ina (mA/cm2)
	ik (mA/cm2)
	il (mA/cm2)
	inf[3]
	tau[3] (ms)
}

:I'm not sure what the purpose of the mhnp(v*1(/mV)) does


:states can be initialized by the user at the hoc level

INITIAL {
	:mhnp sets inf and tau for the given membrane potential
	mhn(v*1(/mV))
	m = inf[0]
	h = inf[1]
	n = inf[2]
}

BREAKPOINT {
	:MAIN COMPUTATION BLOCK
	:Solve directly calls the "states" derivative

	SOLVE states METHOD cnexp
	ina = pnabar*m*m*m*h*ghk(v, nai, nao)
	ik = pkbar*n*n*ghk(v, ki, ko)
	il = gl*(v - el)
}

:This function takes in the 
:Notice that 

FUNCTION ghk(v(mV), ci(mM), co(mM)) (.001 coul/cm3) {
	:WHAT IS THIS FUNCTION DOING?
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
	mhn(v*1(/mV))
	m' = (inf[0] - m)/tau[0]
	h' = (inf[1] - h)/tau[1]
	n' = (inf[2] - n)/tau[2]
}

UNITSOFF
:This turns unit checking off, making the code more readable
:It is up to the user to make sure that the units are correct

FUNCTION alp(v(mV),i) { LOCAL cel, k :rest = -78  order m,h,n,p
	:Called by the mhnp procedure
	v = v-Vrest
	cel = 37
	:i = 0, m, 1 = h, 2 = n
	if (i==0) {
		:a=1.87 b=25.41 c=5.06
		k = Q10am^((celsius - cel)/10)
		:alp = k*amA*exp(v - amB)/(1 - exp((amB - v)/amC))
		alp = k*amA*vtrap(amB - v,amC)
	}else if (i==1){
		:a=0.55 b= 27.74 c=9.06
		k = Q10ah^((celsius - cel)/10)
		:alp = -1*k*ahA*exp(v + ahB)/(1 - exp((v + ahB)/ahC))
		alp = k*ahA*vtrap(v - ahB,ahC)
	}else{
		:a=0.13 b=35 c=10
		k = Q10an^((celsius - cel)/10)
		:alp = k*anA*exp(v - anB)/(1 - exp((anB - v)/anc))
		alp = k*anA*vtrap(anB - v,anC)
	}	
}


FUNCTION bet(v,i) { LOCAL cel, k :rest = -78  order m,h,n,p
	:See alp function comments
	v = v-Vrest
	cel = 37
	:i = 0, m, 1 = h, 2 = n
	if (i==0) {
		:a=3.97  b=21  c=9.41
		k = Q10bm^((celsius - cel)/10)
		:bet = k*bmA*exp(bmB - v)/(1 - exp((v - bmB)/bmC))
		bet = k*bmA*vtrap(v - bmB,bmC)
	}else if (i==1){
		:a=22.6  b=56  c=12.5
		k = Q10bh^((celsius - cel)/10)
		:bet = k*bhA/(1 + exp((bhB - v)/bhC))
		bet = k*bhA/(1 + exp((bhB - v)/bhC))
	}else{
		:a=0.32  b= 10.  c=10.
		k = Q10bn^((celsius - cel)/10)
		:bet = k*bnA*exp(bnB - v)/(1 - exp((v-bnB)/bnC))
		bet = k*bnA*vtrap(v - bnB,bnC)
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

PROCEDURE mhn(v) {LOCAL a, b :rest = -70
	:Not sure what this line does
	:TABLE variables DEPEND dependencies FROM lowest TO highest WITH tablesize
	:This somehow creates a speedup
	:dependencies -> causes recalculatio of the table
	:usetable_suffix = 0 -> in this case usetable_fh = 0 in the hoc code causes tables not to be used
	:the range is for the arguement, thus the vales are defined from -100 to 100 with 200 values total and interpolated inbetween
	
	
	TABLE inf, tau DEPEND celsius FROM -100 TO 100 WITH 200
	FROM i=0 TO 2 {
		a = alp(v,i)  
		b=bet(v,i)
		tau[i] = 1/(a + b)
		inf[i] = a/(a + b)
	}
}

UNITSON
