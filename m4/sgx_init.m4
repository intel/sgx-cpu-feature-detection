# SGX_INIT
# --------
# Initialize automake/autoconf with Intel SGX build options.
# Calling this macro from configure.ac will enforce SGX support
# in the build.
AC_DEFUN([SGX_INIT],[
    AS_VAR_IF([ac_cv_sgx_init], [yes], [AC_MSG_ERROR([[already called SGX_INIT or SGX_INIT_OPTIONAL]])])
	AC_ARG_WITH([enclave-libdir],
		[AS_HELP_STRING([--with-enclave-libdir=path],
			[Set the directory where enclave libraries should be installed (default: EPREFIX/libexec)])
		], [enclave_libdir=$withval],
			[enclave_libdir=\$\{exec_prefix\}/libexec])

	AC_ARG_ENABLE([sgx-simulation],
		[AS_HELP_STRING([--enable-sgx-simulation],
			[Use Intel SGX in simulation mode. Implies --enable-sgx (default: disabled)])
		], [sgxsim=${enableval}], [sgxsim=no])

	AC_ARG_WITH([sgx-build],
		[AS_HELP_STRING([--with-sgx-build=debug|prerelease|release],
			[Set Intel SGX build mode (default: debug)])
		], [_sgxbuild=$withval], [_sgxbuild=debug])

	AC_ARG_WITH([sgxssl],
		[AS_HELP_STRING([--with-sgxssl=path],
			[Set the path to your Intel SGX SSL directory (defaults to /opt/intel/sgxssl)])
		], [SGXSSL=$withval],[SGXSSL=/opt/intel/sgxssl])

	AC_ARG_WITH([sgx-toolkit],
		[AS_HELP_STRING([--with-sgx-toolkit=NAME],
			[Specify toolkit to use for the Intel SGX build. Can be one of: intel-sgxsdk, ms-openenclave (default: intel)])
		], [
			AS_IF(
				[test "$withval" != "ms-openenclave" -a "$withval" != "intel-sgxsdk" ],
				[AC_MSG_ERROR([SGX toolkit must be one of "intel-sgxsdk", "ms-openenclave"])],
				[ac_cv_sgx_toolkit=$withval]
			)
		],[ac_cv_sgx_toolkit=intel-sgxsdk])

	AC_ARG_WITH([sgxsdk],
		[AS_HELP_STRING([--with-sgxsdk=DIR],
			[Specify the Intel SGX SDK directory (defaults to auto-detection)])
		], [
			AS_IF(
				[test "$withval" = "yes"],[SGXSDK="detect"],[SGXSDK="$withval"]
			)
		],[SGXSDK="detect"]
	)

	AC_ARG_WITH([openenclave],
		[AS_HELP_STRING([--with-openenclave=DIR],
			[Specify the Open Enclave directory (defaults to /opt/openenclave)])
		],[
			AS_IF(
				[test "$withval" = "yes"],
				[OE=/opt/openenclave],
				[OE="$withval"]
			)
		],[OE=/opt/openenclave]
	)

	AS_IF([test "x$sgxsim" = "yes"], [sgxenable=yes])
	AS_IF([test "x$sgxenable" != "xno"],
		[ac_cv_enable_sgx=yes], [ac_cv_enable_sgx=no])

	AM_CONDITIONAL([SGX_ENABLED], [test "$ac_cv_enable_sgx" = "yes"])
	AM_CONDITIONAL([SGX_WITH_SGXSDK],
		[test "$ac_cv_enable_sgx" = "yes" -a "$ac_cv_sgx_toolkit" = "intel-sgxsdk"])
	AM_CONDITIONAL([SGX_WITH_OPENENCLAVE],
		[test "$ac_cv_enable_sgx" = "yes" -a "$ac_cv_sgx_toolkit" = "ms-openenclave"])
	AM_COND_IF([SGX_ENABLED], [

    	AC_SUBST(enclave_libdir)

    	AC_SUBST(SGXSSL)
    	AC_SUBST(SGXSSL_INCDIR, $SGXSSL/include)
    	AC_SUBST(SGXSSL_LIBDIR, $SGXSSL/lib64)

		AS_IF([test "$ac_cv_sgx_toolkit" = "intel-sgxsdk"],[
			SGX_CONFIG_SGXSDK
		],[
			SGX_CONFIG_OPENENCLAVE
		])
	])

	AM_CONDITIONAL([ENCLAVE_RELEASE_SIGN], [test "x$_sgxbuild" = "xrelease"])
	AM_CONDITIONAL([SGX_HW_SIM], [test "x$sgxsim" = "xyes"])
	ac_cv_sgx_init=yes
])

# SGX_IF_ENABLED(ACTION_IF_TRUE, ACTION_IF_FALSE)
# -----------------------------------------------
# Execute ACTION_IF_TRUE if SGX is enabled for the build
# (SGX_INIT was called in configure.ac, or SGX_INIT_OPTIONAL
# was called and the user supplied --enable-sgx on the
# command line).
AC_DEFUN([SGX_IF_ENABLED],[
	AS_IF([test "x${ac_cv_enable_sgx}" = "xyes"], [$1], [$2])
])

# SGX_USING_SGXSDK(ACTION_IF_TRUE, ACTION_IF_FALSE)
# -------------------------------------------------
# Execute ACTION_IF_TRUE if SGX is enabled for a build
# using the Intel SGX SDK.
AC_DEFUN([SGX_USING_SGXSDK],[
	AS_IF([test "x${ac_cv_sgx_toolkit}" = "xintel-sgxsdk"], [$1], [$2])
])

# SGX_USING_OPENENCLAVE(ACTION_IF_TRUE, ACTION_IF_FALSE)
# -------------------------------------------------
# Execute ACTION_IF_TRUE if SGX is enabled for a build
# using Open Enclave.
AC_DEFUN([SGX_USING_OPENENCLAVE],[
	AS_IF([test "x${ac_cv_sgx_toolkit}" = "xms-openenclave"], [$1], [$2])
])

