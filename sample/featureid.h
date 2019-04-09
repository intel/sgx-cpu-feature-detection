#ifndef __FEATURES__H
#define __FEATURES__H

#include <stdint.h>

#define REGISTER_EAX 0
#define REGISTER_EBX 1
#define REGISTER_ECX 2
#define REGISTER_EDX 3

typedef struct feature_name_struct {
	uint32_t leaf;
	uint32_t subleaf;
	uint8_t bit;
	uint8_t reg;
	const char *name;
} feature_name_t;

const feature_name_t features[]= {
	{ 7, 0, 19, REGISTER_EBX, "ADX" },
	{ 1, 0, 25, REGISTER_ECX, "AESNI" },
	{ 1, 0, 28, REGISTER_ECX, "AVX" },
	{ 7, 0, 5,  REGISTER_EBX, "AVX2" },
	{ 7, 0, 16, REGISTER_EBX, "AVX512F" },
	{ 7, 0, 17, REGISTER_EBX, "AVX512DQ" },
	{ 7, 0, 31, REGISTER_EBX, "AVX512VL" },
	{ 7, 0, 3,  REGISTER_EBX, "BMI1" },
	{ 7, 0, 8,  REGISTER_EBX, "BMI2" },
	{ 1, 0, 29, REGISTER_ECX, "F16C" },
	{ 1, 0, 12, REGISTER_ECX, "FMA" },
	{ 1, 0, 23, REGISTER_EDX, "MMX" },
	{ 1, 0, 1,  REGISTER_ECX, "PCLMULQDQ" },
	{ 1, 0, 23, REGISTER_ECX, "POPCNT" },
	{ 1, 0, 30, REGISTER_ECX, "RDRAND" },
	{ 7, 0, 18, REGISTER_EBX, "RDSEED" },
	{ 7, 0, 29, REGISTER_EBX, "SHA" },
	{ 1, 0, 25, REGISTER_EDX, "SSE" },
	{ 1, 0, 26, REGISTER_EDX, "SSE2" },
	{ 1, 0, 0,  REGISTER_ECX, "SSE3" },
	{ 1, 0, 9,  REGISTER_ECX, "SSSE3" },
	{ 1, 0, 19, REGISTER_ECX, "SSE4.1" },
	{ 1, 0, 20, REGISTER_ECX, "SSE4.2" },
	{ 0, 0, 0, 0, 0 }
};

#endif
