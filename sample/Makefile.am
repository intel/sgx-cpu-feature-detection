## This must come first when building an application that uses Intel
## SGX enclaves. It can build against the Intel SGX SDK or Microsoft's
## OpenEnclave

include $(top_srcdir)/build-aux/sgx_app.am

SUBDIRS = EnclaveFeatureId


## Needed to make our pattern rule work

EnclaveFeatureId.edl: EnclaveFeatureId/EnclaveFeatureId.edl
	ln -s $?


AM_CPPFLAGS += -fno-builtin-memset 

## Additional targets to remove with 'make clean'. You must list
## any edger8r generated files here.

CLEANFILES = EnclaveFeatureId_u.c EnclaveFeatureId_u.h EnclaveFeatureId.edl \
	EnclaveFeatureId_args.h EnclaveFeatureId.signed.so

## The build target

bin_PROGRAMS = featureid 

## Copy the signed enclave to the current directory

EnclaveFeatureId.signed.so: EnclaveFeatureId/EnclaveFeatureId.signed.so
	ln -s $?

## You can't use $(wildcard ...) with automake so all source files 
## have to be explicitly listed.

featureid_SOURCES = featureid.c
nodist_featureid_SOURCES = EnclaveFeatureId_u.c EnclaveFeatureId_u.h
BUILT_SOURCES = EnclaveFeatureId_u.c EnclaveFeatureId_u.h
EXTRA_featureid_DEPENDENCIES = EnclaveFeatureId.signed.so

## Library flags. At minimum, an Intel SGX SDK application will need:
##
##   -l$(SGX_URTS_LIB)
##
## Applications that use platform services or perform attestation
## will also need:
##
##  -l$(SGX_UA_SERVICE_LIB)
##
## Use the variables, not the actualy library names to ensure these
## targets work on simulation builds.
##
## OpenEnclave applications need, at minimum, $(OE_APP_LIBS)

if SGX_WITH_SGXSDK
featureid_LDADD=-l$(SGX_URTS_LIB) -ldl -l:libsgx_capable.a -lpthread
else
featureid_LDADD=$(OE_APP_LIBS)
endif

