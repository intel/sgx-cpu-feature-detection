#include "config.h"
#include "EnclaveFeatureId_t.h"

#include "sgx_tcpu_features.h"

#ifdef SGX_WITH_SGXSDK
#include <sgx_trts.h>
#include <sgx_cpuid.h>
#else 
#include <openenclave/enclave.h>
#endif

int enclave_cpu_features_mask(int info[4], int leaf, int subleaf)
{
	return sgx_cpu_features_mask(info, leaf, subleaf);
}

int enclave_sgx_cpuid_features_merge(int info[4], int leaf)
{
	return sgx_cpuidex_features_merge(info, (int) leaf, 0);
}

int enclave_sgx_cpuidex_features_merge(int info[4], int leaf, int subleaf)
{
#ifdef SGX_WITH_SGXSDK
	sgx_cpuidex(info, leaf, subleaf);
#else
	oe_oc_cpuid(info, leaf, subleaf);
#endif
	return sgx_cpuidex_features_merge(info, (int) leaf, (int) subleaf);
}

