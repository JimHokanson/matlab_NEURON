%{

NAME: extracellular_stim_mechanism

NEURON DOCUMENATION:
http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/mech.html#extracellular
http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/geometry.html#Section


          Ra		
o/`--o--'\/\/`--o--'\/\/`--o--'\/\/`--o--'\o vext + v
     |          |          |          |     
    ---        ---        ---        ---
   |   |      |   |      |   |      |   |
    ---        ---        ---        ---
     |          |          |          |     
     |          |          |          |     i_membrane     
     |  xraxial |          |          |
 /`--o--'\/\/`--o--'\/\/`--o--'\/\/`--o--'\ vext
     |          |          |          |     
    ---        ---        ---        ---     xc and xg
   |   |      |   |      |   |      |   |    in  parallel
    ---        ---        ---        ---
     |          |          |          |     
     |          |          |          |     
     |xraxial[1]|          |          |     
 /`--o--'\/\/`--o--'\/\/`--o--'\/\/`--o--'\ vext[1]
     |          |          |          |     
    ---        ---        ---        ---     the series xg[1], e_extracellular
   |   |      |   |      |   |      |   |    combination is in parallel with
   |  ---     |  ---     |  ---     |  ---   the xc[1] capacitance. This is
   |   -      |   -      |   -      |   -    identical to a membrane with
    ---        ---        ---        ---     cm, g_pas, e_pas
     |          |          |          |     
-------------------------------------------- ground


insert extracellular
vext[i]     -- mV
i_membrane  -- mA/cm2
xraxial[i]  -- MOhms/cm
xg[i]	    -- mho/cm2
xc[i]	    -- uF/cm2
e_extracellular -- mV


PASSIVE MECHANISM:
---------------------------------------------------------------------------
http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/mech.html#pas
insert pas
g_pas -- mho/cm2	conductance
e_pas -- mV	 reversal potential
i -- mA/cm2	 non-specific current

CAPACITIVE MECHANISM
---------------------------------------------------------------------------
http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/mech.html#capacitance
cm (uF/cm2)
i_cap (mA/cm2)

Capacitance is a mechanism that automatically is inserted into every section.

Default: 1 uF/cm2

C = e_r*e_0*A/d





AXIAL RESISTIVITY
--------------------------------------------------------------------
Ra - (Units Ohm-cm)
http://www.neuron.yale.edu/neuron/static/docs/help/neuron/neuron/geometry.html#Ra

rho = R*A/L

Capacitance - Passive
----------------------------------------------------------------------





%}