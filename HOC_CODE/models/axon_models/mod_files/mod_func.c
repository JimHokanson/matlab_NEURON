#include <stdio.h>
#include "hocdec.h"
#define IMPORT extern __declspec(dllimport)
IMPORT int nrnmpi_myid, nrn_nobanner_;

modl_reg(){
	//nrn_mswindll_stdio(stdin, stdout, stderr);
    if (!nrn_nobanner_) if (nrnmpi_myid < 1) {
	fprintf(stderr, "Additional mechanisms from files\n");

fprintf(stderr," crrss.mod");
fprintf(stderr," crrssGrill.mod");
fprintf(stderr," fh.mod");
fprintf(stderr," hh2.mod");
fprintf(stderr," se.mod");
fprintf(stderr," srb.mod");
fprintf(stderr, "\n");
    }
_crrss_reg();
_crrssGrill_reg();
_fh_reg();
_hh2_reg();
_se_reg();
_srb_reg();
}
