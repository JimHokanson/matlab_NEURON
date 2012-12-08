/* Created by Language version: 6.2.0 */
/* NOT VECTORIZED */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "scoplib.h"
#undef PI
 
#include "md1redef.h"
#include "section.h"
#include "md2redef.h"

#if METHOD3
extern int _method3;
#endif

#undef exp
#define exp hoc_Exp
extern double hoc_Exp();
 
#define _threadargscomma_ /**/
#define _threadargs_ /**/
 	/*SUPPRESS 761*/
	/*SUPPRESS 762*/
	/*SUPPRESS 763*/
	/*SUPPRESS 765*/
	 extern double *getarg();
 static double *_p; static Datum *_ppvar;
 
#define t nrn_threads->_t
#define dt nrn_threads->_dt
#define pnabar _p[0]
#define gkbar _p[1]
#define gksbar _p[2]
#define gl _p[3]
#define el _p[4]
#define il _p[5]
#define iks _p[6]
#define m _p[7]
#define h _p[8]
#define n _p[9]
#define s _p[10]
#define nai _p[11]
#define nao _p[12]
#define ki _p[13]
#define ko _p[14]
#define Dm _p[15]
#define Dh _p[16]
#define Dn _p[17]
#define Ds _p[18]
#define ina _p[19]
#define ik _p[20]
#define _g _p[21]
#define _ion_nai	*_ppvar[0]._pval
#define _ion_nao	*_ppvar[1]._pval
#define _ion_ina	*_ppvar[2]._pval
#define _ion_dinadv	*_ppvar[3]._pval
#define _ion_ki	*_ppvar[4]._pval
#define _ion_ko	*_ppvar[5]._pval
#define _ion_ik	*_ppvar[6]._pval
#define _ion_dikdv	*_ppvar[7]._pval
 
#if MAC
#if !defined(v)
#define v _mlhv
#endif
#if !defined(h)
#define h _mlhh
#endif
#endif
 static int hoc_nrnpointerindex =  -1;
 /* external NEURON variables */
 extern double celsius;
 /* declaration of user functions */
 static int _hoc_alp();
 static int _hoc_bet();
 static int _hoc_efun();
 static int _hoc_ghk();
 static int _hoc_mhns();
 static int _hoc_vtrap();
 static int _mechtype;
extern int nrn_get_mechtype();
 static _hoc_setdata() {
 Prop *_prop, *hoc_getdata_range();
 _prop = hoc_getdata_range(_mechtype);
 _p = _prop->param; _ppvar = _prop->dparam;
 ret(1.);
}
 /* connect user functions to hoc names */
 static IntFunc hoc_intfunc[] = {
 "setdata_srb", _hoc_setdata,
 "alp_srb", _hoc_alp,
 "bet_srb", _hoc_bet,
 "efun_srb", _hoc_efun,
 "ghk_srb", _hoc_ghk,
 "mhns_srb", _hoc_mhns,
 "vtrap_srb", _hoc_vtrap,
 0, 0
};
#define alp alp_srb
#define bet bet_srb
#define efun efun_srb
#define ghk ghk_srb
#define vtrap vtrap_srb
 extern double alp();
 extern double bet();
 extern double efun();
 extern double ghk();
 extern double vtrap();
 /* declare global and static user variables */
#define Q10bs Q10bs_srb
 double Q10bs = 3;
#define Q10as Q10as_srb
 double Q10as = 3;
#define Q10bn Q10bn_srb
 double Q10bn = 3;
#define Q10an Q10an_srb
 double Q10an = 3;
#define Q10bh Q10bh_srb
 double Q10bh = 2.9;
#define Q10ah Q10ah_srb
 double Q10ah = 2.9;
#define Q10bm Q10bm_srb
 double Q10bm = 2.2;
#define Q10am Q10am_srb
 double Q10am = 2.2;
#define Vrest Vrest_srb
 double Vrest = -84;
#define asC asC_srb
 double asC = 23.6;
#define asB asB_srb
 double asB = 71.5;
#define asA asA_srb
 double asA = 0.00122;
#define anC anC_srb
 double anC = 1.1;
#define anB anB_srb
 double anB = -9.2;
#define anA anA_srb
 double anA = 0.00798;
#define ahC ahC_srb
 double ahC = 11;
#define ahB ahB_srb
 double ahB = -27;
#define ahA ahA_srb
 double ahA = 0.0336;
#define amC amC_srb
 double amC = 10.3;
#define amB amB_srb
 double amB = 65.6;
#define amA amA_srb
 double amA = 1.86;
#define bsC bsC_srb
 double bsC = 21.8;
#define bsB bsB_srb
 double bsB = 3.9;
#define bsA bsA_srb
 double bsA = 0.000739;
#define bnC bnC_srb
 double bnC = 10.5;
#define bnB bnB_srb
 double bnB = 8;
#define bnA bnA_srb
 double bnA = 0.0142;
#define bhC bhC_srb
 double bhC = 13.4;
#define bhB bhB_srb
 double bhB = 55.2;
#define bhA bhA_srb
 double bhA = 2.3;
#define bmC bmC_srb
 double bmC = 9.16;
#define bmB bmB_srb
 double bmB = 61.3;
#define bmA bmA_srb
 double bmA = 0.086;
#define ek ek_srb
 double ek = -84;
#define inf inf_srb
 double inf[4];
#define tau tau_srb
 double tau[4];
#define usetable usetable_srb
 double usetable = 1;
 /* some parameters have upper and lower limits */
 static HocParmLimits _hoc_parm_limits[] = {
 "usetable_srb", 0, 1,
 0,0,0
};
 static HocParmUnits _hoc_parm_units[] = {
 "ek_srb", "mV",
 "Vrest_srb", "mV",
 "tau_srb", "ms",
 "pnabar_srb", "cm/s",
 "gkbar_srb", "S/cm2",
 "gl_srb", "mho/cm2",
 "el_srb", "mV",
 "il_srb", "mA/cm2",
 "iks_srb", "mA/cm2",
 0,0
};
 static double delta_t = 1;
 static double h0 = 0;
 static double m0 = 0;
 static double n0 = 0;
 static double s0 = 0;
 static double v = 0;
 /* connect global user variables to hoc */
 static DoubScal hoc_scdoub[] = {
 "ek_srb", &ek_srb,
 "Vrest_srb", &Vrest_srb,
 "amA_srb", &amA_srb,
 "amB_srb", &amB_srb,
 "amC_srb", &amC_srb,
 "ahA_srb", &ahA_srb,
 "ahB_srb", &ahB_srb,
 "ahC_srb", &ahC_srb,
 "anA_srb", &anA_srb,
 "anB_srb", &anB_srb,
 "anC_srb", &anC_srb,
 "asA_srb", &asA_srb,
 "asB_srb", &asB_srb,
 "asC_srb", &asC_srb,
 "bmA_srb", &bmA_srb,
 "bmB_srb", &bmB_srb,
 "bmC_srb", &bmC_srb,
 "bhA_srb", &bhA_srb,
 "bhB_srb", &bhB_srb,
 "bhC_srb", &bhC_srb,
 "bnA_srb", &bnA_srb,
 "bnB_srb", &bnB_srb,
 "bnC_srb", &bnC_srb,
 "bsA_srb", &bsA_srb,
 "bsB_srb", &bsB_srb,
 "bsC_srb", &bsC_srb,
 "Q10am_srb", &Q10am_srb,
 "Q10bm_srb", &Q10bm_srb,
 "Q10ah_srb", &Q10ah_srb,
 "Q10bh_srb", &Q10bh_srb,
 "Q10an_srb", &Q10an_srb,
 "Q10bn_srb", &Q10bn_srb,
 "Q10as_srb", &Q10as_srb,
 "Q10bs_srb", &Q10bs_srb,
 "usetable_srb", &usetable_srb,
 0,0
};
 static DoubVec hoc_vdoub[] = {
 "inf_srb", inf_srb, 4,
 "tau_srb", tau_srb, 4,
 0,0,0
};
 static double _sav_indep;
 static void nrn_alloc(), nrn_init(), nrn_state();
 static void nrn_cur(), nrn_jacob();
 
static int _ode_count(), _ode_map(), _ode_spec(), _ode_matsol();
 
#define _cvode_ieq _ppvar[8]._i
 /* connect range variables in _p that hoc is supposed to know about */
 static char *_mechanism[] = {
 "6.2.0",
"srb",
 "pnabar_srb",
 "gkbar_srb",
 "gksbar_srb",
 "gl_srb",
 "el_srb",
 0,
 "il_srb",
 "iks_srb",
 0,
 "m_srb",
 "h_srb",
 "n_srb",
 "s_srb",
 0,
 0};
 static Symbol* _na_sym;
 static Symbol* _k_sym;
 
static void nrn_alloc(_prop)
	Prop *_prop;
{
	Prop *prop_ion, *need_memb();
	double *_p; Datum *_ppvar;
 	_p = nrn_prop_data_alloc(_mechtype, 22, _prop);
 	/*initialize range parameters*/
 	pnabar = 0.00704;
 	gkbar = 0.03;
 	gksbar = 0.06;
 	gl = 0.06;
 	el = -84;
 	_prop->param = _p;
 	_prop->param_size = 22;
 	_ppvar = nrn_prop_datum_alloc(_mechtype, 9, _prop);
 	_prop->dparam = _ppvar;
 	/*connect ionic variables to this model*/
 prop_ion = need_memb(_na_sym);
 nrn_promote(prop_ion, 1, 0);
 	_ppvar[0]._pval = &prop_ion->param[1]; /* nai */
 	_ppvar[1]._pval = &prop_ion->param[2]; /* nao */
 	_ppvar[2]._pval = &prop_ion->param[3]; /* ina */
 	_ppvar[3]._pval = &prop_ion->param[4]; /* _ion_dinadv */
 prop_ion = need_memb(_k_sym);
 nrn_promote(prop_ion, 1, 0);
 	_ppvar[4]._pval = &prop_ion->param[1]; /* ki */
 	_ppvar[5]._pval = &prop_ion->param[2]; /* ko */
 	_ppvar[6]._pval = &prop_ion->param[3]; /* ik */
 	_ppvar[7]._pval = &prop_ion->param[4]; /* _ion_dikdv */
 
}
 static _initlists();
  /* some states have an absolute tolerance */
 static Symbol** _atollist;
 static HocStateTolerance _hoc_state_tol[] = {
 0,0
};
 static void _update_ion_pointer(Datum*);
 _srb_reg() {
	int _vectorized = 0;
  _initlists();
 	ion_reg("na", -10000.);
 	ion_reg("k", -10000.);
 	_na_sym = hoc_lookup("na_ion");
 	_k_sym = hoc_lookup("k_ion");
 	register_mech(_mechanism, nrn_alloc,nrn_cur, nrn_jacob, nrn_state, nrn_init, hoc_nrnpointerindex, 0);
 _mechtype = nrn_get_mechtype(_mechanism[1]);
     _nrn_thread_reg(_mechtype, 2, _update_ion_pointer);
  hoc_register_dparam_size(_mechtype, 9);
 	hoc_register_cvode(_mechtype, _ode_count, _ode_map, _ode_spec, _ode_matsol);
 	hoc_register_tolerance(_mechtype, _hoc_state_tol, &_atollist);
 	hoc_register_var(hoc_scdoub, hoc_vdoub, hoc_intfunc);
 	ivoc_help("help ?1 srb /cygdrive/C/D/SVN_FOLDERS/Analysis/NeuronModeling/models/axon_General/neuron_code/mod_files/srb.mod\n");
 hoc_register_limits(_mechtype, _hoc_parm_limits);
 hoc_register_units(_mechtype, _hoc_parm_units);
 }
 static double FARADAY = 96485.3;
 static double R = 8.31342;
 static double *_t_inf[4];
 static double *_t_tau[4];
static int _reset;
static char *modelname = "SRB channel";

static int error;
static int _ninits = 0;
static int _match_recurse=1;
static _modl_cleanup(){ _match_recurse=1;}
static _f_mhns();
static mhns();
 
static int _ode_spec1(), _ode_matsol1();
 static _n_mhns();
 static int _slist1[4], _dlist1[4];
 static int states();
 
double ghk (  _lv , _lci , _lco )  
	double _lv , _lci , _lco ;
 {
   double _lghk;
 double _lz , _leco , _leci ;
 _lz = ( 1e-3 ) * FARADAY * _lv / ( R * ( celsius + 273.15 ) ) ;
   _leco = _lco * efun ( _threadargscomma_ _lz ) ;
   _leci = _lci * efun ( _threadargscomma_ - _lz ) ;
   _lghk = ( .001 ) * FARADAY * ( _leci - _leco ) ;
   
return _lghk;
 }
 
static int _hoc_ghk() {
  double _r;
   _r =  ghk (  *getarg(1) , *getarg(2) , *getarg(3) ) ;
 ret(_r);
}
 
double efun (  _lz )  
	double _lz ;
 {
   double _lefun;
 if ( fabs ( _lz ) < 1e-6 ) {
     _lefun = 1.0 - _lz / 2.0 ;
     }
   else {
     _lefun = _lz / ( exp ( _lz ) - 1.0 ) ;
     }
   
return _lefun;
 }
 
static int _hoc_efun() {
  double _r;
   _r =  efun (  *getarg(1) ) ;
 ret(_r);
}
 
/*CVODE*/
 static int _ode_spec1 () {_reset=0;
 {
   mhns ( _threadargscomma_ v * 1.0 ) ;
   Dm = ( inf [ 0 ] - m ) / tau [ 0 ] ;
   Dh = ( inf [ 1 ] - h ) / tau [ 1 ] ;
   Dn = ( inf [ 2 ] - n ) / tau [ 2 ] ;
   Ds = ( inf [ 3 ] - s ) / tau [ 3 ] ;
   }
 return _reset;
}
 static int _ode_matsol1 () {
 mhns ( _threadargscomma_ v * 1.0 ) ;
 Dm = Dm  / (1. - dt*( ( ( ( - 1.0 ) ) ) / tau[0] )) ;
 Dh = Dh  / (1. - dt*( ( ( ( - 1.0 ) ) ) / tau[1] )) ;
 Dn = Dn  / (1. - dt*( ( ( ( - 1.0 ) ) ) / tau[2] )) ;
 Ds = Ds  / (1. - dt*( ( ( ( - 1.0 ) ) ) / tau[3] )) ;
}
 /*END CVODE*/
 static int states () {_reset=0;
 {
   mhns ( _threadargscomma_ v * 1.0 ) ;
    m = m + (1. - exp(dt*(( ( ( - 1.0 ) ) ) / tau[0])))*(- ( ( ( inf[0] ) ) / tau[0] ) / ( ( ( ( - 1.0) ) ) / tau[0] ) - m) ;
    h = h + (1. - exp(dt*(( ( ( - 1.0 ) ) ) / tau[1])))*(- ( ( ( inf[1] ) ) / tau[1] ) / ( ( ( ( - 1.0) ) ) / tau[1] ) - h) ;
    n = n + (1. - exp(dt*(( ( ( - 1.0 ) ) ) / tau[2])))*(- ( ( ( inf[2] ) ) / tau[2] ) / ( ( ( ( - 1.0) ) ) / tau[2] ) - n) ;
    s = s + (1. - exp(dt*(( ( ( - 1.0 ) ) ) / tau[3])))*(- ( ( ( inf[3] ) ) / tau[3] ) / ( ( ( ( - 1.0) ) ) / tau[3] ) - s) ;
   }
  return 0;
}
 
double alp (  _lv , _li )  
	double _lv , _li ;
 {
   double _lalp;
 double _lk ;
 _lv = _lv - Vrest ;
   if ( _li  == 0.0 ) {
     _lk = pow( Q10am , ( ( celsius - 20.0 ) / 10.0 ) ) ;
     _lalp = _lk * amA * vtrap ( _threadargscomma_ amB - _lv , amC ) ;
     }
   else if ( _li  == 1.0 ) {
     _lk = pow( Q10ah , ( ( celsius - 20.0 ) / 10.0 ) ) ;
     _lalp = _lk * ahA * vtrap ( _threadargscomma_ _lv - ahB , ahC ) ;
     }
   else if ( _li  == 2.0 ) {
     _lk = pow( Q10an , ( ( celsius - 20.0 ) / 10.0 ) ) ;
     _lalp = _lk * anA * vtrap ( _threadargscomma_ anB - _lv , anC ) ;
     }
   else {
     _lk = pow( Q10as , ( ( celsius - 20.0 ) / 10.0 ) ) ;
     _lalp = _lk * asA * vtrap ( _threadargscomma_ asB - _lv , asC ) ;
     }
   
return _lalp;
 }
 
static int _hoc_alp() {
  double _r;
   _r =  alp (  *getarg(1) , *getarg(2) ) ;
 ret(_r);
}
 
double bet (  _lv , _li )  
	double _lv , _li ;
 {
   double _lbet;
 double _lk ;
 _lv = _lv - Vrest ;
   if ( _li  == 0.0 ) {
     _lk = pow( Q10bm , ( ( celsius - 20.0 ) / 10.0 ) ) ;
     _lbet = _lk * bmA * vtrap ( _threadargscomma_ _lv - bmB , bmC ) ;
     }
   else if ( _li  == 1.0 ) {
     _lk = pow( Q10bh , ( ( celsius - 20.0 ) / 10.0 ) ) ;
     _lbet = _lk * bhA / ( 1.0 + exp ( ( bhB - _lv ) / bhC ) ) ;
     }
   else if ( _li  == 2.0 ) {
     _lk = pow( Q10bn , ( ( celsius - 20.0 ) / 10.0 ) ) ;
     _lbet = _lk * bnA * vtrap ( _threadargscomma_ _lv - bnB , bnC ) ;
     }
   else {
     _lk = pow( Q10bs , ( ( celsius - 20.0 ) / 10.0 ) ) ;
     _lbet = _lk * bsA * vtrap ( _threadargscomma_ _lv - bsB , bsC ) ;
     }
   
return _lbet;
 }
 
static int _hoc_bet() {
  double _r;
   _r =  bet (  *getarg(1) , *getarg(2) ) ;
 ret(_r);
}
 
double vtrap (  _lx , _ly )  
	double _lx , _ly ;
 {
   double _lvtrap;
 if ( fabs ( _lx / _ly ) < 1e-6 ) {
     _lvtrap = _ly * ( 1.0 - _lx / _ly / 2.0 ) ;
     }
   else {
     _lvtrap = _lx / ( exp ( _lx / _ly ) - 1.0 ) ;
     }
   
return _lvtrap;
 }
 
static int _hoc_vtrap() {
  double _r;
   _r =  vtrap (  *getarg(1) , *getarg(2) ) ;
 ret(_r);
}
 static double _mfac_mhns, _tmin_mhns;
 static _check_mhns();
 static _check_mhns() {
  static int _maktable=1; int _i, _j, _ix = 0;
  double _xi, _tmax;
  static double _sav_celsius;
  if (!usetable) {return;}
  if (_sav_celsius != celsius) { _maktable = 1;}
  if (_maktable) { double _x, _dx; _maktable=0;
   _tmin_mhns =  - 100.0 ;
   _tmax =  100.0 ;
   _dx = (_tmax - _tmin_mhns)/200.; _mfac_mhns = 1./_dx;
   for (_i=0, _x=_tmin_mhns; _i < 201; _x += _dx, _i++) {
    _f_mhns(_x);
    for (_j = 0; _j < 4; _j++) { _t_inf[_j][_i] = inf[_j];
}    for (_j = 0; _j < 4; _j++) { _t_tau[_j][_i] = tau[_j];
}   }
   _sav_celsius = celsius;
  }
 }

 static mhns(double _lv){ _check_mhns();
 _n_mhns(_lv);
 return;
 }

 static _n_mhns(double _lv){ int _i, _j;
 double _xi, _theta;
 if (!usetable) {
 _f_mhns(_lv); return; 
}
 _xi = _mfac_mhns * (_lv - _tmin_mhns);
 _i = (int) _xi;
 if (_xi <= 0.) {
 for (_j = 0; _j < 4; _j++) { inf[_j] = _t_inf[_j][0];
} for (_j = 0; _j < 4; _j++) { tau[_j] = _t_tau[_j][0];
} return; }
 if (_i >= 200) {
 for (_j = 0; _j < 4; _j++) { inf[_j] = _t_inf[_j][200];
} for (_j = 0; _j < 4; _j++) { tau[_j] = _t_tau[_j][200];
} return; }
 _theta = _xi - (double)_i;
 for (_j = 0; _j < 4; _j++) {double *_t = _t_inf[_j]; inf[_j] = _t[_i] + _theta*(_t[_i+1] - _t[_i]);}
 for (_j = 0; _j < 4; _j++) {double *_t = _t_tau[_j]; tau[_j] = _t[_i] + _theta*(_t[_i+1] - _t[_i]);}
 }

 
static int  _f_mhns (  _lv )  
	double _lv ;
 {
   double _la , _lb ;
 {int  _li ;for ( _li = 0 ; _li <= 3 ; _li ++ ) {
     _la = alp ( _threadargscomma_ _lv , ((double) _li ) ) ;
     _lb = bet ( _threadargscomma_ _lv , ((double) _li ) ) ;
     tau [ _li ] = 1.0 / ( _la + _lb ) ;
     inf [ _li ] = _la / ( _la + _lb ) ;
     } }
    return 0; }
 
static int _hoc_mhns() {
  double _r;
    _r = 1.;
 mhns (  *getarg(1) ) ;
 ret(_r);
}
 
static int _ode_count(_type) int _type;{ return 4;}
 
static int _ode_spec(_NrnThread* _nt, _Memb_list* _ml, int _type) {
   Datum* _thread;
   Node* _nd; double _v; int _iml, _cntml;
  _cntml = _ml->_nodecount;
  _thread = _ml->_thread;
  for (_iml = 0; _iml < _cntml; ++_iml) {
    _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
    _nd = _ml->_nodelist[_iml];
    v = NODEV(_nd);
  nai = _ion_nai;
  nao = _ion_nao;
  ki = _ion_ki;
  ko = _ion_ko;
     _ode_spec1 ();
   }}
 
static int _ode_map(_ieq, _pv, _pvdot, _pp, _ppd, _atol, _type) int _ieq, _type; double** _pv, **_pvdot, *_pp, *_atol; Datum* _ppd; { 
 	int _i; _p = _pp; _ppvar = _ppd;
	_cvode_ieq = _ieq;
	for (_i=0; _i < 4; ++_i) {
		_pv[_i] = _pp + _slist1[_i];  _pvdot[_i] = _pp + _dlist1[_i];
		_cvode_abstol(_atollist, _atol, _i);
	}
 }
 
static int _ode_matsol(_NrnThread* _nt, _Memb_list* _ml, int _type) {
   Datum* _thread;
   Node* _nd; double _v; int _iml, _cntml;
  _cntml = _ml->_nodecount;
  _thread = _ml->_thread;
  for (_iml = 0; _iml < _cntml; ++_iml) {
    _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
    _nd = _ml->_nodelist[_iml];
    v = NODEV(_nd);
  nai = _ion_nai;
  nao = _ion_nao;
  ki = _ion_ki;
  ko = _ion_ko;
 _ode_matsol1 ();
 }}
 extern void nrn_update_ion_pointer(Symbol*, Datum*, int, int);
 static void _update_ion_pointer(Datum* _ppvar) {
   nrn_update_ion_pointer(_na_sym, _ppvar, 0, 1);
   nrn_update_ion_pointer(_na_sym, _ppvar, 1, 2);
   nrn_update_ion_pointer(_na_sym, _ppvar, 2, 3);
   nrn_update_ion_pointer(_na_sym, _ppvar, 3, 4);
   nrn_update_ion_pointer(_k_sym, _ppvar, 4, 1);
   nrn_update_ion_pointer(_k_sym, _ppvar, 5, 2);
   nrn_update_ion_pointer(_k_sym, _ppvar, 6, 3);
   nrn_update_ion_pointer(_k_sym, _ppvar, 7, 4);
 }

static void initmodel() {
  int _i; double _save;_ninits++;
 _save = t;
 t = 0.0;
{
  h = h0;
  m = m0;
  n = n0;
  s = s0;
 {
   mhns ( _threadargscomma_ v * 1.0 ) ;
   m = inf [ 0 ] ;
   h = inf [ 1 ] ;
   n = inf [ 2 ] ;
   s = inf [ 3 ] ;
   }
  _sav_indep = t; t = _save;

}
}

static void nrn_init(_NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; double _v; int* _ni; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
#if CACHEVEC
  if (use_cachevec) {
    _v = VEC_V(_ni[_iml]);
  }else
#endif
  {
    _nd = _ml->_nodelist[_iml];
    _v = NODEV(_nd);
  }
 v = _v;
  nai = _ion_nai;
  nao = _ion_nao;
  ki = _ion_ki;
  ko = _ion_ko;
 initmodel();
  }}

static double _nrn_current(double _v){double _current=0.;v=_v;{ {
   ina = pnabar * m * m * m * h * ghk ( _threadargscomma_ v , nai , nao ) ;
   ik = gkbar * n * n * n * n * ( v - ek ) ;
   iks = s * gksbar * ( v - ek ) ;
   il = gl * ( v - el ) ;
   }
 _current += ina;
 _current += ik;
 _current += il;
 _current += iks;

} return _current;
}

static void nrn_cur(_NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; int* _ni; double _rhs, _v; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
#if CACHEVEC
  if (use_cachevec) {
    _v = VEC_V(_ni[_iml]);
  }else
#endif
  {
    _nd = _ml->_nodelist[_iml];
    _v = NODEV(_nd);
  }
  nai = _ion_nai;
  nao = _ion_nao;
  ki = _ion_ki;
  ko = _ion_ko;
 _g = _nrn_current(_v + .001);
 	{ double _dik;
 double _dina;
  _dina = ina;
  _dik = ik;
 _rhs = _nrn_current(_v);
  _ion_dinadv += (_dina - ina)/.001 ;
  _ion_dikdv += (_dik - ik)/.001 ;
 	}
 _g = (_g - _rhs)/.001;
  _ion_ina += ina ;
  _ion_ik += ik ;
#if CACHEVEC
  if (use_cachevec) {
	VEC_RHS(_ni[_iml]) -= _rhs;
  }else
#endif
  {
	NODERHS(_nd) -= _rhs;
  }
 
}}

static void nrn_jacob(_NrnThread* _nt, _Memb_list* _ml, int _type){
Node *_nd; int* _ni; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml];
#if CACHEVEC
  if (use_cachevec) {
	VEC_D(_ni[_iml]) += _g;
  }else
#endif
  {
     _nd = _ml->_nodelist[_iml];
	NODED(_nd) += _g;
  }
 
}}

static void nrn_state(_NrnThread* _nt, _Memb_list* _ml, int _type){
 double _break, _save;
Node *_nd; double _v; int* _ni; int _iml, _cntml;
#if CACHEVEC
    _ni = _ml->_nodeindices;
#endif
_cntml = _ml->_nodecount;
for (_iml = 0; _iml < _cntml; ++_iml) {
 _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
 _nd = _ml->_nodelist[_iml];
#if CACHEVEC
  if (use_cachevec) {
    _v = VEC_V(_ni[_iml]);
  }else
#endif
  {
    _nd = _ml->_nodelist[_iml];
    _v = NODEV(_nd);
  }
 _break = t + .5*dt; _save = t;
 v=_v;
{
  nai = _ion_nai;
  nao = _ion_nao;
  ki = _ion_ki;
  ko = _ion_ko;
 { {
 for (; t < _break; t += dt) {
 error =  states();
 if(error){fprintf(stderr,"at line 173 in file srb.mod:\n	SOLVE states METHOD cnexp\n"); nrn_complain(_p); abort_run(error);}
 
}}
 t = _save;
 }  }}

}

static terminal(){}

static _initlists() {
 int _i; static int _first = 1;
  if (!_first) return;
 _slist1[0] = &(m) - _p;  _dlist1[0] = &(Dm) - _p;
 _slist1[1] = &(h) - _p;  _dlist1[1] = &(Dh) - _p;
 _slist1[2] = &(n) - _p;  _dlist1[2] = &(Dn) - _p;
 _slist1[3] = &(s) - _p;  _dlist1[3] = &(Ds) - _p;
  for (_i=0; _i < 4; _i++) {  _t_inf[_i] = makevector(201*sizeof(double)); }
  for (_i=0; _i < 4; _i++) {  _t_tau[_i] = makevector(201*sizeof(double)); }
_first = 0;
}
