## This line must come first when building an Intel SGX enclave.

include $(top_srcdir)/build-aux/sgx_tlib.am

AM_CPPFLAGS+= -I..

if SGX_WITH_SGXSDK
lib_LIBRARIES = libsgx_tcpu_features_sgxsdk.a
libsgx_tcpu_features_sgxsdk_a_SOURCES = sgx_tcpu_features.h \
	sgx_tcpu_features.c cpuid_merge.c
else
lib_LIBRARIES = libsgx_tcpu_features_oe.a
libsgx_tcpu_features_oe_a_SOURCES = sgx_tcpu_features.h \
	sgx_tcpu_features.c cpuid_merge.c
endif

include_HEADERS = sgx_tcpu_features.h
BUILT_SOURCES = sgx_tcpu_features.c

GENERATOR=gen_featureid

sgx_tcpu_features.c: ops.json $(GENERATOR)
	./$(GENERATOR) ops.json > $@

