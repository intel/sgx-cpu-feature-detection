AC_INIT(featureid, 1.0, john.p.mechalas@intel.com)

AC_CONFIG_MACRO_DIRS([m4])
AM_INIT_AUTOMAKE([foreign])

AC_PROG_CC
AC_PROG_CXX
AC_PROG_CPP
AM_PROG_CC_C_O
AC_PROG_RANLIB

SGX_INIT()

SGX_TSTDC_CHECK_HEADERS_PREFIX([stdio.h])
SGX_TSTDC_CHECK_FUNCS_PREFIX([fprintf])

SGX_USING_SGXSDK([
	AC_SUBST([EDL_IMPORTS], ["from \"sgx_tstdc.edl\" import *;"])
],[
	AC_SUBST(EDL_IMPORTS, [ ])
])

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([
	Makefile 
	src/Makefile 
	sample/Makefile
	sample/EnclaveFeatureId/Makefile
	sample/EnclaveFeatureId/EnclaveFeatureId.edl
])

AC_OUTPUT()

