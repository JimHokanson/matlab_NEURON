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
#define gnabar _p[0]
#define ena _p[1]
#define gl _p[2]
#define el _p[3]
#define il _p[4]
#define m _p[5]
#define h _p[6]
#define Dm _p[7]
#define Dh _p[8]
#define ina _p[9]
#define _g _p[10]
#define _ion_ina	*_ppvar[0]._pval
#define _ion_dinadv	*_ppvar[1]._pval
 
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
 static int _hoc_mh();
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
 "setdata_crrssGrill", _hoc_setdata,
 "mh_crrssGrill", _hoc_mh,
 0, 0
};
 /* declare global and static user variables */
#define Vrest Vrest_crrssGrill
 double Vrest = -80;
#define ahB ahB_crrssGrill
 double ahB = 15.6;
#define ahA ahA_crrssGrill
 double ahA = 24;
#define amD amD_crrssGrill
 double amD = 5.3;
#define amC amC_crrssGrill
 double amC = 0.363;
#define amB amB_crrssGrill
 double amB = 97;
#define amA amA_crrssGrill
 double amA = 31;
#define bhC bhC_crrssGrill
 double bhC = 5;
#define bhB bhB_crrssGrill
 double bhB = -5.5;
#define bhA bhA_crrssGrill
 double bhA = 10;
#define bmB bmB_crrssGrill
 double bmB = 4.17;
#define bmA bmA_crrssGrill
 double bmA = -23.8;
#define inf inf_crrssGrill
 double inf[2];
#define tau tau_crrssGrill
 double tau[2];
#define usetable usetable_crrssGrill
 double usetable = 1;
 /* some parameters have upper and lower limits */
 static HocParmLimits _hoc_parm_limits[] = {
 "usetable_crrssGrill", 0, 1,
 0,0,0
};
 static HocParmUnits _hoc_parm_units[] = {
 "Vrest_crrssGrill", "mV",
 "amA_crrssGrill", "mV",
 "amB_crrssGrill", "1/ms",
 "amC_crrssGrill", "1/ms*mV",
 "amD_crrssGrill", "mV",
 "bmA_crrssGrill", "mV",
 "bmB_crrssGrill", "mV",
 "ahA_crrssGrill", "mV",
 "ahB_crrssGrill", "1/ms",
 "bhA_crrssGrill", "mV",
 "bhB_crrssGrill", "mV",
 "bhC_crrssGrill", "mV",
 "tau_crrssGrill", "ms",
 "gnabar_crrssGrill", "mho/cm2",
 "ena_crrssGrill", "mV",
 "gl_crrssGrill", "mho/cm2",
 "el_crrssGrill", "mV",
 "il_crrssGrill", "mA/cm2",
 0,0
};
 static double delta_t = 1;
 static double h0 = 0;
 static double m0 = 0;
 static double v = 0;
 /* connect global user variables to hoc */
 static DoubScal hoc_scdoub[] = {
 "Vrest_crrssGrill", &Vrest_crrssGrill,
 "amA_crrssGrill", &amA_crrssGrill,
 "amB_crrssGrill", &amB_crrssGrill,
 "amC_crrssGrill", &amC_crrssGrill,
 "amD_crrssGrill", &amD_crrssGrill,
 "bmA_crrssGrill", &bmA_crrssGrill,
 "bmB_crrssGrill", &bmB_crrssGrill,
 "ahA_crrssGrill", &ahA_crrssGrill,
 "ahB_crrssGrill", &ahB_crrssGrill,
 "bhA_crrssGrill", &bhA_crrssGrill,
 "bhB_crrssGrill", &bhB_crrssGrill,
 "bhC_crrssGrill", &bhC_crrssGrill,
 "usetable_crrssGrill", &usetable_crrssGrill,
 0,0
};
 static DoubVec hoc_vdoub[] = {
 "inf_crrssGrill", inf_crrssGrill, 2,
 "tau_crrssGrill", tau_crrssGrill, 2,
 0,0,0
};
 static double _sav_indep;
 static void nrn_alloc(), nrn_init(), nrn_state();
 static void nrn_cur(), nrn_jacob();
 
static int _ode_count(), _ode_map(), _ode_spec(), _ode_matsol();
 
#define _cvode_ieq _ppvar[2]._i
 /* connect range variables in _p that hoc is supposed to know about */
 static char *_mechanism[] = {
 "6.2.0",
"crrssGrill",
 "gnabar_crrssGrill",
 "ena_crrssGrill",
 "gl_crrssGrill",
 "el_crrssGrill",
 0,
 "il_crrssGrill",
 0,
 "m_crrssGrill",
 "h_crrssGrill",
 0,
 0};
 static Symbol* _na_sym;
 
static void nrn_alloc(_prop)
	Prop *_prop;
{
	Prop *prop_ion, *need_memb();
	double *_p; Datum *_ppvar;
 	_p = nrn_prop_data_alloc(_mechtype, 11, _prop);
 	/*initialize range parameters*/
 	gnabar = 2.168;
 	ena = 64;
 	gl = 0.128;
 	el = -80.01;
 	_prop->param = _p;
 	_prop->param_size = 11;
 	_ppvar = nrn_prop_datum_alloc(_mechtype, 3, _prop);
 	_prop->dparam = _ppvar;
 	/*connect ionic variables to this model*/
 prop_ion = need_memb(_na_sym);
 	_ppvar[0]._pval = &prop_ion->param[3]; /* ina */
 	_ppvar[1]._pval = &prop_ion->param[4]; /* _ion_dinadv */
 
}
 static _initlists();
  /* some states have an absolute tolerance */
 static Symbol** _atollist;
 static HocStateTolerance _hoc_state_tol[] = {
 0,0
};
 static void _update_ion_pointer(Datum*);
 _crrssGrill_reg() {
	int _vectorized = 0;
  _initlists();
 	ion_reg("na", -10000.);
 	_na_sym = hoc_lookup("na_ion");
 	register_mech(_mechanism, nrn_alloc,nrn_cur, nrn_jacob, nrn_state, nrn_init, hoc_nrnpointerindex, 0);
 _mechtype = nrn_get_mechtype(_mechanism[1]);
     _nrn_thread_reg(_mechtype, 2, _update_ion_pointer);
  hoc_register_dparam_size(_mechtype, 3);
 	hoc_register_cvode(_mechtype, _ode_count, _ode_map, _ode_spec, _ode_matsol);
 	hoc_register_tolerance(_mechtype, _hoc_state_tol, &_atollist);
 	hoc_register_var(hoc_scdoub, hoc_vdoub, hoc_intfunc);
 	ivoc_help("help ?1 crrssGrill /cygdrive/C/respositories/matlabToolboxes/NEURON/HOC_CODE/models/axon_models/mod_files/crrssGrill.mod\n");
 hoc_register_limits(_mechtype, _hoc_parm_limits);
 hoc_register_units(_mechtype, _hoc_parm_units);
 }
 static double FARADAY = 96485.3;
 static double R = 8.31342;
 static double *_t_inf[2];
 static double *_t_tau[2];
static int _reset;
static char *modelname = "CRRSS channel";

static int error;
static int _ninits = 0;
static int _match_recurse=1;
static _modl_cleanup(){ _match_recurse=1;}
static _f_mh();
static mh();
 
static int _ode_spec1(), _ode_matsol1();
 static _n_mh();
 static int _slist1[2], _dlist1[2];
 static int states();
 
/*CVODE*/
 static int _ode_spec1 () {_reset=0;
 {
   mh ( _threadargscomma_ v * 1.0 ) ;
   Dm = ( inf [ 0 ] - m ) / tau [ 0 ] ;
   Dh = ( inf [ 1 ] - h ) / tau [ 1 ] ;
   }
 return _reset;
}
 static int _ode_matsol1 () {
 mh ( _threadargscomma_ v * 1.0 ) ;
 Dm = Dm  / (1. - dt*( ( ( ( - 1.0 ) ) ) / tau[0] )) ;
 Dh = Dh  / (1. - dt*( ( ( ( - 1.0 ) ) ) / tau[1] )) ;
}
 /*END CVODE*/
 static int states () {_reset=0;
 {
   mh ( _threadargscomma_ v * 1.0 ) ;
    m = m + (1. - exp(dt*(( ( ( - 1.0 ) ) ) / tau[0])))*(- ( ( ( inf[0] ) ) / tau[0] ) / ( ( ( ( - 1.0) ) ) / tau[0] ) - m) ;
    h = h + (1. - exp(dt*(( ( ( - 1.0 ) ) ) / tau[1])))*(- ( ( ( inf[1] ) ) / tau[1] ) / ( ( ( ( - 1.0) ) ) / tau[1] ) - h) ;
   }
  return 0;
}
 static double _mfac_mh, _tmin_mh;
 static _check_mh();
 static _check_mh() {
  static int _maktable=1; int _i, _j, _ix = 0;
  double _xi, _tmax;
  static double _sav_celsius;
  if (!usetable) {return;}
  if (_sav_celsius != celsius) { _maktable = 1;}
  if (_maktable) { double _x, _dx; _maktable=0;
   _tmin_mh =  - 100.0 ;
   _tmax =  100.0 ;
   _dx = (_tmax - _tmin_mh)/200.; _mfac_mh = 1./_dx;
   for (_i=0, _x=_tmin_mh; _i < 201; _x += _dx, _i++) {
    _f_mh(_x);
    for (_j = 0; _j < 2; _j++) { _t_inf[_j][_i] = inf[_j];
}    for (_j = 0; _j < 2; _j++) { _t_tau[_j][_i] = tau[_j];
}   }
   _sav_celsius = celsius;
  }
 }

 static mh(double _lv){ _check_mh();
 _n_mh(_lv);
 return;
 }

 static _n_mh(double _lv){ int _i, _j;
 double _xi, _theta;
 if (!usetable) {
 _f_mh(_lv); return; 
}
 _xi = _mfac_mh * (_lv - _tmin_mh);
 _i = (int) _xi;
 if (_xi <= 0.) {
 for (_j = 0; _j < 2; _j++) { inf[_j] = _t_inf[_j][0];
} for (_j = 0; _j < 2; _j++) { tau[_j] = _t_tau[_j][0];
} return; }
 if (_i >= 200) {
 for (_j = 0; _j < 2; _j++) { inf[_j] = _t_inf[_j][200];
} for (_j = 0; _j < 2; _j++) { tau[_j] = _t_tau[_j][200];
} return; }
 _theta = _xi - (double)_i;
 for (_j = 0; _j < 2; _j++) {double *_t = _t_inf[_j]; inf[_j] = _t[_i] + _theta*(_t[_i+1] - _t[_i]);}
 for (_j = 0; _j < 2; _j++) {double *_t = _t_tau[_j]; tau[_j] = _t[_i] + _theta*(_t[_i+1] - _t[_i]);}
 }

 
static int  _f_mh (  _lv )  
	double _lv ;
 {
   double _lam , _lbm , _lah , _lbh , _lk ;
 _lv = _lv - Vrest ;
   _lk = pow( 3.0 , ( ( celsius - 37.0 ) / 10.0 ) ) ;
   _lam = ( amB + amC * _lv ) / ( 1.0 + exp ( ( amA - _lv ) / amD ) ) * _lk ;
   _lbm = _lam / ( exp ( ( _lv + bmA ) / bmB ) ) * _lk ;
   _lbh = ahB / ( 1.0 + exp ( ( ahA - _lv ) / bhA ) ) * _lk ;
   _lah = _lbh / ( exp ( ( _lv + bhB ) / bhC ) ) * _lk ;
   tau [ 0 ] = 1.0 / ( _lam + _lbm ) ;
   inf [ 0 ] = _lam / ( _lam + _lbm ) ;
   tau [ 1 ] = 1.0 / ( _lah + _lbh ) ;
   inf [ 1 ] = _lah / ( _lah + _lbh ) ;
    return 0; }
 
static int _hoc_mh() {
  double _r;
    _r = 1.;
 mh (  *getarg(1) ) ;
 ret(_r);
}
 
static int _ode_count(_type) int _type;{ return 2;}
 
static int _ode_spec(_NrnThread* _nt, _Memb_list* _ml, int _type) {
   Datum* _thread;
   Node* _nd; double _v; int _iml, _cntml;
  _cntml = _ml->_nodecount;
  _thread = _ml->_thread;
  for (_iml = 0; _iml < _cntml; ++_iml) {
    _p = _ml->_data[_iml]; _ppvar = _ml->_pdata[_iml];
    _nd = _ml->_nodelist[_iml];
    v = NODEV(_nd);
     _ode_spec1 ();
  }}
 
static int _ode_map(_ieq, _pv, _pvdot, _pp, _ppd, _atol, _type) int _ieq, _type; double** _pv, **_pvdot, *_pp, *_atol; Datum* _ppd; { 
 	int _i; _p = _pp; _ppvar = _ppd;
	_cvode_ieq = _ieq;
	for (_i=0; _i < 2; ++_i) {
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
 _ode_matsol1 ();
 }}
 extern void nrn_update_ion_pointer(Symbol*, Datum*, int, int);
 static void _update_ion_pointer(Datum* _ppvar) {
   nrn_update_ion_pointer(_na_sym, _ppvar, 0, 3);
   nrn_update_ion_pointer(_na_sym, _ppvar, 1, 4);
 }

static void initmodel() {
  int _i; double _save;_ninits++;
 _save = t;
 t = 0.0;
{
  h = h0;
  m = m0;
 {
   mh ( _threadargscomma_ v * 1.0 ) ;
   m = inf [ 0 ] ;
   h = inf [ 1 ] ;
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
 initmodel();
 }}

static double _nrn_current(double _v){double _current=0.;v=_v;{ {
   double _ldrForNa ;
 ina = gnabar * m * m * h * ( v - ena ) ;
   il = gl * ( v - el ) ;
   }
 _current += ina;
 _current += il;

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
 _g = _nrn_current(_v + .001);
 	{ double _dina;
  _dina = ina;
 _rhs = _nrn_current(_v);
  _ion_dinadv += (_dina - ina)/.001 ;
 	}
 _g = (_g - _rhs)/.001;
  _ion_ina += ina ;
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
 { {
 for (; t < _break; t += dt) {
 error =  states();
 if(error){fprintf(stderr,"at line 146 in file crrssGrill.mod:\n	:drForNa = Nernst(v, nai, nao)\n"); nrn_complain(_p); abort_run(error);}
 
}}
 t = _save;
 } }}

}

static terminal(){}

static _initlists() {
 int _i; static int _first = 1;
  if (!_first) return;
 _slist1[0] = &(m) - _p;  _dlist1[0] = &(Dm) - _p;
 _slist1[1] = &(h) - _p;  _dlist1[1] = &(Dh) - _p;
  for (_i=0; _i < 2; _i++) {  _t_inf[_i] = makevector(201*sizeof(double)); }
  for (_i=0; _i < 2; _i++) {  _t_tau[_i] = makevector(201*sizeof(double)); }
_first = 0;
}
