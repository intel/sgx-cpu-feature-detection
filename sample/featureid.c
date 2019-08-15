#include "config.h"

#include "featureid.h" 

#ifdef SGX_WITH_SGXSDK
# include <sgx_urts.h>
#else
# include <cpuid.h>
# include <openenclave/host.h>
#endif

#include "EnclaveFeatureId_u.h"

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <immintrin.h>

#define ENCLAVE_NAME "EnclaveFeatureId.signed.so"

const char *bitfield[16]= {
	"0000", "0001", "0010", "0011",
	"0100", "0101", "0110", "0111",
	"1000", "1001", "1010", "1011",
	"1100", "1101", "1110", "1111"
};

typedef struct _enclave_meta_struct {
#ifdef SGX_WITH_SGXSDK
        sgx_launch_token_t token;
        int updated;
        sgx_enclave_id_t enclave;
        sgx_misc_attribute_t *attr;
#else
        oe_enclave_type_t type;
        void *config;
        uint32_t config_size;
        oe_enclave_t *enclave;
#endif
} enclave_meta_t;

const char *sbyte(unsigned char byte);

void featurebits (int leaf, int subleaf, uint32_t info[4]);
void featurenames (int leaf, int subleaf, uint32_t info[4]);

int do_ecall_features_mask (enclave_meta_t *e, int info[4], int leaf,
	int subleaf);
int do_ecall_features (enclave_meta_t *e, int info[4], int leaf,
	int subleaf);

int launch_enclave(enclave_meta_t *e);

int main (int argc, char **argv)
{
	int info[4];
	enclave_meta_t e;
	memset(&e, 0, sizeof(e));

	if ( launch_enclave(&e) == 0 ) {
		exit(1);
	}

	printf("------------ Feature detection masks -------------------\n\n");

	if ( do_ecall_features_mask(&e, info, 1, 0) ) {
		featurebits(1, 0, (uint32_t *) info);
		featurenames(1, 0, (uint32_t *) info);
	}

	if ( do_ecall_features_mask(&e, info, 7, 0) ) {
		featurebits(7, 0, (uint32_t *) info);
		featurenames(7, 0, (uint32_t *) info);
	}

	printf("\n------------ Detected features -------------------------\n\n");

	if ( do_ecall_features(&e, info, 1, 0) ) {
		featurebits(1, 0, (uint32_t *) info);
		featurenames(1, 0, (uint32_t *) info);
	}

	if ( do_ecall_features(&e, info, 7, 0) ) {
		featurebits(7, 0, (uint32_t *) info);
		featurenames(7, 0, (uint32_t *) info);
	}

	return 0;
}

void featurebits (int leaf, int subleaf, uint32_t info[4])
{
	int i;
	printf("Leaf %u, subleaf %u:\n", leaf, subleaf);
    printf("        31    24 23    16 15     8 7      0\n");
	for (i= 0; i< 4; ++i) {
		printf("  E%cX = %s%s %s%s %s%s %s%s = 0x%08x\n", 65+i,
			sbyte((info[i]>>28)&0xF), sbyte((info[i]>>24)&0xF),
			sbyte((info[i]>>20)&0xF), sbyte((info[i]>>16)&0xF),
			sbyte((info[i]>>12)&0xF), sbyte((info[i]>>8)&0xF),
			sbyte((info[i]>>4)&0xF), sbyte(info[i]&0xF),
			info[i]
		);
	}
	printf("\n");
}

void featurenames (int leaf, int subleaf, uint32_t info[4])
{
	const feature_name_t *flist= features;
	printf("  Features:");
	while ( flist->name ) {
		if ( flist->leaf == leaf && flist->subleaf == subleaf &&
			(1<<(flist->bit))&info[flist->reg] ) printf(" %s", flist->name);
		++flist;
	}
	printf("\n\n");
}

int do_ecall_features (enclave_meta_t *e, int info[4], int leaf, int subleaf)
{
	int rv= 0;
#ifdef SGX_WITH_SGXSDK
	sgx_status_t status= SGX_SUCCESS;
#else
	oe_result_t status= OE_OK;
#endif

	status= enclave_sgx_cpuidex_features_merge(e->enclave, &rv, info,
		leaf, subleaf);
#ifdef SGX_WITH_SGXSDK
	if ( status != SGX_SUCCESS ) {
		fprintf(stderr, "ECALL enclave_cpu_features: %08x\n", status);
		return 0;
	}
#else
	if ( status != OE_OK ) {
		fprintf(stderr, "ECALL enclave_cpu_features: %s\n", 
			oe_result_str(status));
		return 0;
	}
#endif

	return (rv == 0);
}

int do_ecall_features_mask (enclave_meta_t *e, int info[4], int leaf,
	int subleaf)
{
	int rv= 0;
#ifdef SGX_WITH_SGXSDK
	sgx_status_t status= SGX_SUCCESS;
#else
	oe_result_t status= OE_OK;
#endif

	status= enclave_cpu_features_mask(e->enclave, &rv, info, leaf, subleaf);
#ifdef SGX_WITH_SGXSDK
	if ( status != SGX_SUCCESS ) {
		fprintf(stderr, "ECALL enclave_cpu_features_mask: %08x\n", status);
		return 0;
	}
#else
	if ( status != OE_OK ) {
		fprintf(stderr, "ECALL enclave_cpu_features_mask: %s\n", 
			oe_result_str(status));
		return 0;
	}
#endif

	return (rv == 0);
}

int launch_enclave(enclave_meta_t *e)
{
#ifdef SGX_WITH_SGXSDK
	sgx_status_t status;

	memset(e->token, 0, sizeof(e->token));
	e->updated= 0;
	e->enclave= 0;
	e->attr= NULL;

	status= sgx_create_enclave(ENCLAVE_NAME, SGX_DEBUG_FLAG, &e->token,
		&e->updated, &e->enclave, e->attr);
	if ( status != SGX_SUCCESS ) {
		if ( status == SGX_ERROR_ENCLAVE_FILE_ACCESS ) {
			fprintf(stderr, "sgx_create_enclave: %s: file not found\n",
				ENCLAVE_NAME);
		} else {
			fprintf(stderr, "sgx_create_enclave: %s: %08x\n", ENCLAVE_NAME,
				status);
		}

		return 0;
	}


#else
	uint32_t flags= 0;
	oe_result_t status;

	e->type= OE_ENCLAVE_TYPE_SGX;
# if SGX_DEBUG_FLAG
	flags|= OE_ENCLAVE_FLAG_DEBUG
# endif

	status= oe_create_enclave(ENCLAVE_NAME, e->type, flags, e->config,
		e->config_size, NULL, 0, &e->enclave);
	if ( status != OE_OK ) {
		fprintf(stderr, "oe_create_enclave: %s: %s\n", ENCLAVE_NAME,
			oe_result_str(status));

		return 0;
	}
#endif

	return 1;
}

const char *sbyte(unsigned char byte) 
{
	return bitfield[byte];
}

void oe_oc_cpuid(int info[4], int leaf, int subleaf)
{
#ifdef SGX_WITH_OPENENCLAVE
	__cpuid_count(leaf, subleaf, info[0], info[1], info[2], info[3]);
#endif
}

