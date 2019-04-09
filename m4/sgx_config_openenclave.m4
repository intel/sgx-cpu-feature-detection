# SGX_CONFIG_OPENENCLAVE()
# ------------------------
# Configure the SGX build for Open Enclave. This macro should not
# be called directly. It's invoked by SGX_INIT.
AC_DEFUN([SGX_CONFIG_OPENENCLAVE],[
	AC_DEFINE([SGX_WITH_OPENENCLAVE], 1,
		[Define if building for SGX with OpenEnclave])

	AS_IF([test "x$sgxsim" = "xyes"], [
			AC_DEFINE(SGX_HW_SIM, 1, [Enable hardware simulation mode])
		]
	)
	AS_IF([test "x$_sgxbuild" = "xdebug"], [
			oe_debug=1
			AC_SUBST(ENCLAVE_SIGN_TARGET, [signed_enclave_dev])
		],
		[test "x$_sgxbuild" = "xprerelease"], [
			oe_debug=1
			AC_SUBST(ENCLAVE_SIGN_TARGET, [signed_enclave_dev])
		],
		[test "x$_sgxbuild" = "xrelease"], [
			oe_debug=0
			AS_IF(test "x$_sgxsim" = "xyes", [
				AC_MSG_ERROR([Can't build in both release and simulation mode])
			],
			[
				AC_SUBST(ENCLAVE_SIGN_TARGET, [signed_enclave_rel])
			])
		],
		[AC_MSG_ERROR([Unknown build mode $_sgxbuild])]
	)

	AC_DEFINE_UNQUOTED(OE_DEBUG_FLAG, $oe_debug, [Enable enclave debugging (Open Enclave)])
	AC_SUBST(OE)
	AC_SUBST(OE_INCDIR, $OE/include)

	ac_cv_openenclave=$OE
	ac_cv_openenclave_incdir=$OE/include

	AS_IF([test -d $OE/bin], [
		ac_cv_openenclave_bindir=$OE/bin
		AC_SUBST(OE_BINDIR, [$OE/bin])
	], [
		AC_MSG_ERROR(Can't find Open Enclave bin directory)
	])

	AS_IF([test -d $OE/lib], [
		ac_cv_openenclave_libdir=$OE/lib
		AC_SUBST(OE_LIBDIR, [$OE/lib])
	], [
		AC_MSG_ERROR(Can't find the Open Enclave bin directory)
	])

	AC_MSG_NOTICE([found Open Enclave in $OE])

	export PKG_CONFIG_PATH=$OE/share/pkgconfig

	ac_cv_sgx_app_cflags="`pkg-config --cflags-only-other oehost-${ac_ct_CC}` ${SGX_TSTDC_CFLAGS}"
	ac_cv_sgx_app_cppflags="`pkg-config --cflags-only-I oehost-${ac_ct_CC}` ${SGX_TSTDC_CPPFLAGS}"
	ac_cv_sgx_app_cxxflags="`pkg-config --cflags-only-other oehost-${ac_ct_CC}` ${SGX_TSTDC_CXXFLAGS}"
	ac_cv_sgx_app_ldflags="`pkg-config --libs-only-L --libs-only-other oehost-${ac_ct_CXX}` ${SGX_TSTDC_LDFLAGS}"
	ac_cv_sgx_app_ldadd="`pkg-config --libs-only-l oehost-${ac_ct_CXX}`"

	ac_cv_sgx_enclave_cflags="`pkg-config --cflags-only-other oeenclave-${ac_ct_CC}` ${SGX_TSTDC_CFLAGS}"
	ac_cv_sgx_enclave_cppflags="`pkg-config --cflags-only-I oeenclave-${ac_ct_CC}` ${SGX_TSTDC_CPPFLAGS}"
	ac_cv_sgx_enclave_cxxflags="`pkg-config --cflags-only-other oeenclave-${ac_ct_CC}` ${SGX_TSTDC_CXXFLAGS}"
	ac_cv_sgx_enclave_ldflags="`pkg-config --libs-only-L --libs-only-other oeenclave-${ac_ct_CXX}` ${SGX_TSTDC_LDFLAGS}"
	ac_cv_sgx_enclave_ldadd="`pkg-config --libs-only-l oeenclave-${ac_ct_CXX}`"

	dnl Substitutions for building a trusted library (these 
	dnl use the same compiler flags as enclaves)

	AC_SUBST(OE_TLIB_CFLAGS, [$ac_cv_sgx_enclave_cflags])
	AC_SUBST(OE_TLIB_CPPFLAGS, [$ac_cv_sgx_enclave_cppflags])
	AC_SUBST(OE_TLIB_CXXFLAGS, [ac_cv_sgx_enclave_cxxflags])

	dnl Substitutions for building an enclave

	AC_SUBST(OE_ENCLAVE_CFLAGS, [$ac_cv_sgx_enclave_cflags])
	AC_SUBST(OE_ENCLAVE_CPPFLAGS, [$ac_cv_sgx_enclave_cppflags])
	AC_SUBST(OE_ENCLAVE_CXXFLAGS, [$ac_cv_sgx_enclave_cxxflags])
	AC_SUBST(OE_ENCLAVE_LDFLAGS, [$ac_cv_sgx_enclave_ldflags])
	AC_SUBST(OE_ENCLAVE_LDADD, [$ac_cv_sgx_enclave_ldadd])

	dnl Substitutions for building an app

	AC_SUBST(OE_APP_CFLAGS, [$ac_cv_sgx_app_cflags])
	AC_SUBST(OE_APP_CPPFLAGS, [$ac_cv_sgx_app_cppflags])
	AC_SUBST(OE_APP_CXXFLAGS, [$ac_cv_sgx_app_cxxflags])
	AC_SUBST(OE_APP_LDFLAGS, [$ac_cv_sgx_app_ldflags])
	AC_SUBST(OE_APP_LDADD, [$ac_cv_sgx_app_ldadd])

	dnl Substitutions for building an enclave

	AC_MSG_NOTICE([enabling SGX build using OpenEnclave... ${ac_cv_enable_sgx}])
])

