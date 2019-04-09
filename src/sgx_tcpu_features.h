#ifndef __SGX_TCPUID_H
#define __SGX_TCPUID_H

#include <stdint.h>

#define SGX_TCPUID_UNKNOWN         -9999
#define SGX_TCPUID_UNSUPPORTEDLEAF -1
#define SGX_TCPUID_OK              0

#ifdef __cplusplus
extern "C" {
#endif

#define sgx_cpuid_features_merge(i,l) sgx_cpuidex_features_merge(i,l,0)

int sgx_cpuidex_features_merge(int info[4], int leaf, int subleaf);

int sgx_cpu_features(int info[4], int leaf, int subleaf);

int sgx_cpu_features_mask(int info[4], int leaf, int subleaf);

#ifdef __cplusplus
};
#endif

#endif

