## This line must come first when building an Intel SGX enclave.

include $(top_srcdir)/build-aux/sgx_enclave.am

ENCLAVE=EnclaveFeatureId
if SGX_WITH_SGXSDK
ENCLAVE_CONFIG=$(ENCLAVE).config.xml
else
ENCLAVE_CONFIG=$(ENCLAVE).conf
endif
ENCLAVE_KEY=$(ENCLAVE)_private.pem

AM_CPPFLAGS += -I../../src

## Additional files to remove with 'make clean'. This list needs
## to include your edger8r genreated files.

CLEANFILES+= $(ENCLAVE)_t.c $(ENCLAVE)_t.h 


## Put your sources here. Don't forget to list the _t.c and _t.h 
## files. You can't use the $(ENCLAVE) variable in the build
## target name (i.e., $(ENCLAVE)_SOURCES will not work).

EnclaveFeatureId_SOURCES = EnclaveFeatureId_t.c EnclaveFeatureId_t.h \
	EnclaveFeatureId.c \
	$(ENCLAVE_KEY) $(ENCLAVE_CONFIG)
if SGX_WITH_SGXSDK
EXTRA_EnclaveFeatureId_DEPENDENCIES = ../../src/libsgx_tcpu_features_sgxsdk.a
else
EXTRA_EnclaveFeatureId_DEPENDENCIES = ../../src/libsgx_tcpu_features_oe.a
endif

## Add additional linker flags to AM_LDFLAGS here. Don't put 
## libraries flags here (see below).
##
## Be sure to use += to add to, and not replace, the default 
## AM_LDFLAGS.
##

AM_LDFLAGS += -L../../src

## This line is REQUIRED. It can't be generically defined for 
## automake, so you must specify it for your enclave. Note that you
## can't say $(ENCLAVE)_LDADD here: you must spell out the enclave name.
## If you add flags to it, you MUST include @SGX_ENCLAVE_LDADD@ as part
## of the definition to make sure you pick up the right linker flags
## and SGX trusted libraries.

EnclaveFeatureId_LDADD = @SGX_ENCLAVE_LDADD@ @OE_ENCLAVE_LDADD@


## Place any additional trusted libraries that your enclave may need in
## SGX_EXTRA_TLIBS. This will ensure they get place inside the 
## --startgroup and --endgroup flags. (This would be where you'd add
## SGXSSL libraries, and your trusted c++ library

if SGX_WITH_SGXSDK
SGX_EXTRA_TLIBS=-lsgx_tcpu_features_sgxsdk
else
LIBS+=-lsgx_tcpu_features_oe
endif

## This line is OPTIONAL, and comes with a WARNING.
##
## In general, you shouldn't need to use the program-specific LDFLAGS
## instead of AM_LDFLAGS. But, if you need to, then you'll need to ensure
## @SGX_ENCLAVE_LDFLAGS@ is included in the definition as this will 
## override AM_LDFLAGS.
##
## enclave_LDFLAGS = @SGX_ENCLAVE_LDFLAGS@
##

