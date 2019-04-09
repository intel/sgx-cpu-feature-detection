# SGX_CONFIG_SGXSDK()
# -------------------
# Configure the SGX build for the Intel SGX SDK. This macro should not
# be called directly. It's invoked by SGX_INIT.
AC_DEFUN([SGX_CONFIG_SGXSDK],[
	AC_DEFINE([SGX_WITH_SGXSDK], 1,
		[Define if building for SGX with the Intel SGX SDK])
	AS_IF([test "x$sgxsim" = "xyes"], [
			AC_SUBST(SGX_TRTS_LIB, [sgx_trts_sim])
			AC_SUBST(SGX_TSERVICE_LIB, [sgx_tservice_sim])
			AC_SUBST(SGX_UAE_SERVICE_LIB, [sgx_uae_service_sim])
			AC_SUBST(SGX_URTS_LIB, [sgx_urts_sim])
			AC_SUBST(LIBS_HW_SIMU, ["-lsgx_urts_sim -lsgx_uae_service_sim"])
			AC_DEFINE(SGX_HW_SIM, 1, [Enable hardware simulation mode])
		], [
			AC_SUBST(SGX_TRTS_LIB, [sgx_trts])
			AC_SUBST(SGX_TSERVICE_LIB, [sgx_tservice])
			AC_SUBST(SGX_UAE_SERVICE_LIB, [sgx_uae_service])
			AC_SUBST(SGX_URTS_LIB, [sgx_urts])
		]
	)
	AS_IF([test "x$_sgxbuild" = "xdebug"], [
			AC_DEFINE(DEBUG, 1, [Enable enclave debugging (SGX SDK)])
			AC_SUBST(ENCLAVE_SIGN_TARGET, [signed_enclave_dev])
		],
		[test "x$_sgxbuild" = "xprerelease"], [
			AC_DEFINE(NDEBUG, 1, [No app debugging in prerelease and release builds (SGX SDK)])
			AC_DEFINE(EDEBUG, 1, [Enclave debugging in prerelease builds (SGX SDK)])
			AC_SUBST(ENCLAVE_SIGN_TARGET, [signed_enclave_dev])
		],
		[test "x$_sgxbuild" = "xrelease"], [
			AS_IF(test "x$_sgxsim" = "xyes", [
				AC_MSG_ERROR([Can't build in both release and simulation mode])
			],
			[
				AC_DEFINE(NDEBUG, 1, [No enclave debugging in release builds (SGX SDK)])
				AC_SUBST(ENCLAVE_SIGN_TARGET, [signed_enclave_rel])
			])
		],
		[AC_MSG_ERROR([Unknown build mode $_sgxbuild])]
	)
	AS_IF([test "x$SGX_SDK" = "x"], [SGXSDK=detect], [SGXSDK=env])

	AS_IF([test "x$SGXSDK" = "xenv"], [SGXSDK=$SGX_SDK],
		[test "x$SGXSDK" != "xdetect"], [],
		[test -d /opt/intel/sgxsdk], [SGXSDK=/opt/intel/sgxsdk],
		[test -d ~/sgxsdk], [SGXSDK=~/sgxsdk],
		[test -d ./sgxsdk], [SGXSDK=./sgxsdk],
		[AC_MSG_ERROR([Can't detect your Intel SGX SDK installation directory])])

	AC_SUBST(SGXSDK)
	AC_SUBST(SGXSDK_INCDIR, $SGXSDK/include)

	ac_cv_sgx_sdk=$SGXSDK
	ac_cv_sgx_sdk_incdir=$SGXSDK/include

	AS_IF([test -d $SGXSDK/lib], [
		AC_SUBST(SGXSDK_LIBDIR, $SGXSDK/lib)
		ac_cv_sgx_sdk_libdir=$SGXSDK/lib
	], [test -d $SGXSDK/lib64], [
		AC_SUBST(SGXSDK_LIBDIR, $SGXSDK/lib64)
		ac_cv_sgx_sdk_libdir=$SGXSDK/lib64
	], [
		AC_MSG_ERROR(Can't find Intel SGX SDK lib directory)
	])

	AS_IF([test -d $SGXSDK/bin/ia32], [
		ac_cv_sgx_sdk_bindir=$SGXSDK/bin
		AC_SUBST(SGXSDK_BINDIR, $SGXSDK/bin/ia32)
	], [test -d $SGXSDK/bin/x64], [
		ac_cv_sgx_sdk_bindir=$SGXSDK/bin/x64
		AC_SUBST(SGXSDK_BINDIR, $SGXSDK/bin/x64)
	], [
		AC_MSG_ERROR(Can't find Intel SGX SDK bin directory)
	])

	AC_MSG_NOTICE([found Intel SGX SDK in $SGXSDK])

	dnl ----------------------------------------------------------
	dnl Some of these are not defined the same as the Makefile 
	dnl substitution variables since they have to be set in a manner
	dnl that allows autoconf to use them when running the compiler
	dnl and linker for things like header and function checks (see
	dnl SGX_TSTDC_CHECK_*). 

	dnl Trusted Libraries

	ac_cv_sgx_tlib_cppflags="-I${ac_cv_sgx_sdk_incdir} -I${ac_cv_sgx_sdk_incdir}/tlibc ${SGX_TSTDC_CPPFLAGS}"

	ac_cv_sgx_tlib_cflags="-nostdinc -fvisibility=hidden -fpie -fstack-protector ${SGX_TSTDC_CFLAGS}"
	ac_cv_sgx_tlib_cxxflags="-nostdinc++ ${ac_cv_sgx_tlib_cflags} ${SGX_TSTDC_CXXFLAGS}"

	dnl (no ldadd or ldflags since building a library does not invoke 
	dnl the linker)


	dnl Enclaves

	ac_cv_sgx_enclave_cppflags="${ac_cv_sgx_tlib_cppflags} ${SGX_TSTDC_CPPFLAGS=}"

	ac_cv_sgx_enclave_cflags="${ac_cv_sgx_tlib_cflags} -ffunction-sections -fdata-sections ${SGX_TSTDC_CFLAGS=}"
	ac_cv_sgx_enclave_cxxflags="-nostdinc++ ${ac_cv_sgx_enclave_cflags} ${SGX_TSTDC_CXXFLAGS=}"

	ac_cv_sgx_enclave_ldflags="-nostdlib -nodefaultlibs -nostartfiles -L${ac_cv_sgx_sdk_libdir} ${SGX_TSTDC_LDFLAGS}"
	ac_cv_sgx_enclave_ldadd="-Wl,--no-undefined -Wl,--whole-archive -lsgx_trts -Wl,--no-whole-archive -Wl,--start-group -lsgx_tstdc -lsgx_tcrypto -lsgx_tservice_lib -Wl,--end-group -Wl,-Bstatic -Wl,-Bsymbolic -Wl,-pie,-eenclave_entry -Wl,--export-dynamic -Wl,--defsym,__ImageBase=0"

	dnl Substitutions for building an app.

	AC_SUBST(SGX_APP_CFLAGS, [])
	AC_SUBST(SGX_APP_CPPFLAGS, ["-I\$(SGXSDK_INCDIR)"])
	AC_SUBST(SGX_APP_CXXFLAGS, [])
	AC_SUBST(SGX_APP_LDFLAGS, ["-L\$(SGXSDK_LIBDIR)"])
	dnl Assumes you want dynamic linking instead of dynamic loading
	AC_SUBST(SGX_APP_LDADD, ["-l\$(SGX_URTS_LIB) -l\$(SGX_UAE_SERVICE_LIB)"])

	dnl Substitutions for building a trusted library (generally identical
	dnl to building an enclave, only without LDADD).

	AC_SUBST(SGX_TLIB_CFLAGS, [$ac_cv_sgx_tlib_cflags])
	AC_SUBST(SGX_TLIB_CPPFLAGS,
		["-I\$(SGXSDK_INCDIR) -I\$(SGXSDK_INCDIR)/tlibc ${SGX_TSTDC_CPPFLAGS}"])
	AC_SUBST(SGX_TLIB_CXXFLAGS, [$ac_cv_sgx_tlib_cxxflags])

	dnl Substitutions for building an enclave

	AC_SUBST(SGX_ENCLAVE_CFLAGS, [$ac_cv_sgx_enclave_cflags])
	AC_SUBST(SGX_ENCLAVE_CPPFLAGS, 
		["-I\$(SGXSDK_INCDIR) -I\$(SGXSDK_INCDIR)/tlibc ${SGX_TSTDC_CPPFLAGS}"])
	AC_SUBST(SGX_ENCLAVE_CXXFLAGS, [$ac_cv_sgx_enclave_cxxflags])
	AC_SUBST(SGX_ENCLAVE_LDFLAGS,
		["-nostdlib -nodefaultlibs -nostartfiles -L\$(SGXSDK_LIBDIR) ${SGX_TSTDC_LDFLAGS}"])
	AC_SUBST(SGX_ENCLAVE_LDADD,
		["-Wl,--no-undefined -Wl,--whole-archive -l\$(SGX_TRTS_LIB) -Wl,--no-whole-archive -Wl,--start-group \$(SGX_EXTRA_TLIBS) -lsgx_tstdc -lsgx_tcrypto -l\$(SGX_TSERVICE_LIB) -Wl,--end-group -Wl,-Bstatic -Wl,-Bsymbolic -Wl,-pie,-eenclave_entry -Wl,--export-dynamic -Wl,--defsym,__ImageBase=0"])

	])

	AC_MSG_NOTICE([enabling SGX build using the SGX SDK... ${ac_cv_enable_sgx}])
])

