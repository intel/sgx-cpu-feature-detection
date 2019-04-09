#include "config.h"
#include "sgx_tcpu_features.h"

int sgx_cpuidex_features_merge (int cpuinfo[4], int leaf, int subleaf)
{
	int rv, i;
	int info[4], mask[4];

	rv= sgx_cpu_features_mask(mask, leaf, subleaf);
	if ( rv == SGX_TCPUID_UNSUPPORTEDLEAF ) return 0;
	else if ( rv != SGX_TCPUID_OK ) return SGX_TCPUID_UNKNOWN;

	rv= sgx_cpu_features(info, leaf, subleaf);
	if ( rv != SGX_TCPUID_OK ) return SGX_TCPUID_UNKNOWN;

	for (i= 0; i< 4; ++i) {
		cpuinfo[i]&= ~mask[i];
		cpuinfo[i]|= info[i];
	}

	return SGX_TCPUID_OK;
}

