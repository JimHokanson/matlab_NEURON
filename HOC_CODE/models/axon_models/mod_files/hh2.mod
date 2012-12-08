TITLE hh2.mod   squid sodium, potassium, and leak channels
 
COMMENT
--
 This is the original Hodgkin-Huxley treatment for the set of sodium, 
  potassium, and leakage channels found in the squid giant axon membrane.
  ("A quantitative description of membrane current and its application 
  conduction and excitation in nerve" J.Physiol. (Lond.) 117:500-544 (1952).)
 Membrane voltage is in absolute mV and has been reversed in polarity
  from the original HH convention and shifted to reflect a resting potential
  of -65 mV.
 Remember to set celsius=6.3 (or whatever) in your HOC file.
 See squid.hoc for an example of a simulation using this model.
 SW Jaslove  6 March, 1992
 --
ENDCOMMENT
 
UNITS {
        (mA) = (milliamp)
        (mV) = (millivolt)
	(S) = (siemens)
}
 
? interface
NEURON {
        SUFFIX hh2
        USEION na READ ena WRITE ina
        USEION k READ ek WRITE ik
        NONSPECIFIC_CURRENT il
        RANGE gnabar, gkbar, gl, el, gna, gk
        GLOBAL minf, hinf, ninf, mtau, htau, ntau
}
 
PARAMETER {
        gnabar = .12 (S/cm2)	<0,1e9>
        gkbar = 0.036 (S/cm2)	<0,1e9>
        gl = 0.0003 (S/cm2)	<0,1e9>
		
		
		ena (mV) :50  (mV) :Not sure if I can really change this
        ek (mV)  :-77 (mV)
        el = -54.3 (mV)
		Vrest = -70 (mV)
		
		Q10am = 3 
		Q10bm = 3 
		Q10an = 3 
		Q10bn = 3 
		Q10ah = 3 
		Q10bh = 3 
		
}
 
STATE {
        m h n
}
 
ASSIGNED {
    v (mV)
    celsius (degC)
	gna (S/cm2)
	gk (S/cm2)
    ina (mA/cm2)
    ik (mA/cm2)
    il (mA/cm2)
    minf hinf ninf
	mtau (ms) htau (ms) ntau (ms)
}
 
LOCAL mexp, hexp, nexp        
 
? currents
BREAKPOINT {
    SOLVE states METHOD cnexp
    gna = gnabar*m*m*m*h
	ina = gna*(v - ena)
    gk = gkbar*n*n*n*n
	ik = gk*(v - ek)      
    il = gl*(v - el)
}
 
 
INITIAL {
	rates(v)
	m = minf
	h = hinf
	n = ninf
}

? states
DERIVATIVE states {  
        rates(v)
        m' =  (minf-m)/mtau
        h' = (hinf-h)/htau
        n' = (ninf-n)/ntau
}
 
LOCAL q10


? rates
PROCEDURE rates(v(mV)) {  :Computes rate and other constants at current v.
                      :Call once from HOC to initialize inf at resting v.
        LOCAL  alpha, beta, sum
        TABLE minf, mtau, hinf, htau, ninf, ntau DEPEND celsius FROM -100 TO 100 WITH 200

UNITSOFF
       
		v = v - Vrest :This needs to change into a passed in vrest
		
		
		:"m" sodium activation system
		q10 = Q10am^((celsius - 6.3)/10)
		alpha = ((2.5 - 0.1*v)/(exp(2.5-0.1*v)-1))*q10
		q10 = Q10bm^((celsius - 6.3)/10)
		beta = (4*exp(-v/18))*q10
        sum = alpha + beta
		mtau = 1/sum
        minf = alpha/sum
		
        :"h" sodium inactivation system
		q10 = Q10ah^((celsius - 6.3)/10)
        alpha = (0.07*exp(-v/20))*q10
		q10 = Q10bh^((celsius - 6.3)/10)
		beta = (1/(exp(3-0.1*v)+1))*q10
        sum = alpha + beta
		htau = 1/sum
        hinf = alpha/sum
        
		:"n" potassium activation system
		:alpha = ((0.1-0.01*v)/(exp(1-0.1*v)-1))*q10
		q10 = Q10an^((celsius - 6.3)/10)
		alpha = .01*vtrap(-(v-10),10)*q10
		q10 = Q10bn^((celsius - 6.3)/10)
		beta = (0.125*exp(-v/80))*q10
		sum = alpha + beta
        ntau = 1/sum
        ninf = alpha/sum
}

FUNCTION vtrap(x,y) {  :Traps for 0 in denominator of rate eqns.
        if (fabs(x/y) < 1e-6) {
                vtrap = y*(1 - x/y/2)
        }else{
                vtrap = x/(exp(x/y) - 1)
        }
}
 
UNITSON
