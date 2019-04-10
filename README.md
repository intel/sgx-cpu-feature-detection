
# Trusted CPU Feature Detection Library for Intel® Software Guard Extensions (Intel® SGX)

## Introduction

This is a trusted library for Intel® Software Guard Extensions (Intel® SGX) that
performs CPU feature detection for a select list of features and feature
families.

Normally, an application should call the CPUID instruction to detect CPU features, but CPUID cannot be executed inside an enclave. Helper functions from the Intel SGX software development kit (SDK), such as sgx_cpuid() and sgx_cpuidex(), must make OCALLs to untrusted space. The [Intel&reg; Software Guard Extensions SDK developer reference](https://software.intel.com/en-us/sgx-sdk-dev-reference-sgx-cpuid) gives the following warning:

> As the CPUID instruction is executed by an OCALL, the results should not be trusted. Code should verify the results and perform a threat evaluation to determine the impact on trusted code if the results were spoofed.

Enclaves that depend on CPUID results for code path decisions could be manipulated by malicious software into choosing either inefficient algorithms or executing code paths with instructions that aren't supported by the CPU (leading to a #UD exception, which is effectively a denial of service attack). This library allows enclaves to detect CPU features without exiting the trusted runtime environment of the enclave. It supports both the Intel SGX SDK and the Microsoft* Open Enclave* trusted runtimes.

**Note:** This is not a general replacement for the sgx_cpuid() or sgx_cpuidex() calls but rather a supplement. An enclave may still need to call sgx_cpuid(), but those results can be merged with the results obtained from this library to ensure that the presence or absence of supported feature sets is accurately reported.

## Supported features

Feature | CPUID Notation
--------|---------------
ADX | CPUID.07H:EBX.ADX[bit 19]
AESNI | CPUID.01H:ECX.AESNI[bit 25]
AVX | CPUID.01H:ECX.AVX[bit 28]
AVX2 | CPUID.07H:EBX.AVX2[bit 5]
AVX512DQ | CPUID.07H:EBX.AVX512DQ[bit 17]
AVX512F | CPUID.07H:EBX.AVX512F[bit 16]
AVX512VL | CPUID.07H:EBX.AVX512VL[bit 31]
BMI1 | CPUID.07H:EBX.BMI1[bit 3]
BMI2 | CPUID.07H:EBX.BMI2[bit 8]
F16C | CPUID.01H:ECX.F16C[bit 29]
FMA | CPUID.01H:ECX.FMA[bit 12]
MMX | CPUID.01H:EDX.MMX[bit 23]
PCLMULQDQ | CPUID.01H:ECX.PCLMULQDQ[bit 1]
POPCNT | CPUID.01H:ECX.POPCNT[bit 23]
RDRAND | CPUID.01H:ECX.RDRAND[bit 30]
RDSEED | CPUID.07H:EBX.RDSEED[bit 18]
SHA | CPUID.07H:EBX.SHA[bit 29]
SSE | CPUID.01H:EDX.SSE[bit 25]
SSE2 | CPUID.01H:EDX.SSE2[bit 26]
SSE3 | CPUID.01H:ECX.SSE3[bit 0]
SSE4.1 | CPUID.01H:ECX.SSE4_1[bit 19]
SSE4.2 | CPUID.01H:ECX.SSE4_2[bit 20]
SSSE3 | CPUID.01H:ECX.SSSE3[bit 9]

## Building and Installing

To build this library you'll need one of the following software development
kits (SDKs):

   * [Intel SGX SDK](https://github.com/intel/linux-sgx)
   * [Microsoft Open Enclave SDK v0.4.x](https://github.com/Microsoft/openenclave)

You'll also need a C compiler such as gcc* that is supported by the chosen
SDK.

To build the package:

```
$ ./configure
$ make
```

You can specify an installation directory by providing the `--prefix` option
to `configure`.

### Additional 'configure' options

```
--with-sgx-toolkit=NAME Specify toolkit to use for the Intel SGX build. Can
                        be one of: intel-sgxsdk, ms-openenclave (default:
                        intel-sgxsdk)

--with-sgxsdk=DIR       Specify the Intel SGX SDK directory (defaults to
                        auto-detection)

--with-openenclave=DIR  Specify the Open Enclave directory (defaults to
                        /opt/openenclave)
```

Running `make` will build both the trusted library and the sample application.

To install the library:

```
$ sudo make install
```

This will install into /usr/local unless you chose an installation directory
when running `configure`.

## Usage

The recommended way to use this library is to call sgx_cpuid_features_merge()
immediately after executing CPUID in an OCALL. Examples for the Intel SGX SDK
and the [Microsoft* Open Enclave SDK](https://github.com/Microsoft/openenclave)
are shown below.

Note that this library has dependencies on the the trusted runtime, so it must
be built for against the appropriate SDK. The build procedure will append a suffix,
*_sgxsdk* for the Intel SGX SDK and *_oe* for Microsoft's Open Enclave SDK,
so that both versions may co-exist on the same system.

### Intel SGX SDK

```
#include <sgx_tcpu_features.h>
#include <sgx_cpuid.h>

void sample_function(){
    sgx_status_t status;
    int info[4];

    status= sgx_cpuidex(info, 7, 0);
    if ( status == SGX_SUCCESS ) {
        sgx_cpuidex_features_merge(info, 7, 0);
    } else {
        /* Handle error */      
    }
}
```

To link this libary to your enclave, add `-lsgx_tcpu_features_sgxsdk`
to the enclave's list of trusted libraries.

### Microsoft OpenEnclave

```
#include <sgx_tcpu_features.h>
#include <openenclave/enclave.h>

void sample_function(){
    oe_result_t status;
    int info[4];

    status= oe_oc_cpuid(info, 7, 0);
    if ( status == OE_OK ) {
        sgx_cpuidex_features_merge(info, 7, 0);
    } else {
        /* Handle error */      
    }
}
```

To link this libary to your enclave, add `-lsgx_tcpu_features_oe` to the enclave's list of
trusted libraries.


## Sample Application

This library comes with a sample application that prints the features that
are detected on the CPU. It will work with both the Intel SGX SDK and
Microsoft Open Enclave SDK.

Usage is simple:

```
$ ./featureid

------------ Feature detection masks -------------------

Leaf 1, subleaf 0:
        31    24 23    16 15     8 7      0
  EAX = 00000000 00000000 00000000 00000000 = 0x00000000
  EBX = 00000000 00000000 00000000 00000000 = 0x00000000
  ECX = 01110010 10011000 00010010 00000011 = 0x72981203
  EDX = 00000110 10000000 00000000 00000000 = 0x06800000

  Features: AESNI AVX F16C FMA MMX PCLMULQDQ POPCNT RDRAND SSE SSE2 SSE3 SSSE3 SSE4.1 SSE4.2

Leaf 7, subleaf 0:
        31    24 23    16 15     8 7      0
  EAX = 00000000 00000000 00000000 00000000 = 0x00000000
  EBX = 10100000 00001111 00000001 00101000 = 0xa00f0128
  ECX = 00000000 00000000 00000000 00000000 = 0x00000000
  EDX = 00000000 00000000 00000000 00000000 = 0x00000000

  Features: ADX AVX2 AVX512F AVX512DQ AVX512VL BMI1 BMI2 RDSEED SHA

------------ Detected features -------------------------

Leaf 1, subleaf 0:
        31    24 23    16 15     8 7      0
  EAX = 00000000 00001001 00000110 11101010 = 0x000906ea
  EBX = 00000000 00000000 00001000 00000000 = 0x00000800
  ECX = 11111111 11111010 00110010 00100011 = 0xfffa3223
  EDX = 00001111 10001011 11111011 11111111 = 0x0f8bfbff

  Features: AESNI AVX F16C FMA MMX PCLMULQDQ POPCNT RDRAND SSE SSE2 SSE3 SSSE3 SSE4.1 SSE4.2

Leaf 7, subleaf 0:
        31    24 23    16 15     8 7      0
  EAX = 00000000 00000000 00000000 00000000 = 0x00000000
  EBX = 00000000 10011100 01001111 10111111 = 0x009c4fbf
  ECX = 00000000 00000000 00000000 00000100 = 0x00000004
  EDX = 10000100 00000000 00000000 00000000 = 0x84000000

  Features: ADX AVX2 BMI1 BMI2 RDSEED

```
## Methodology

The first time any of these functions are called, the library executes
the trusted CPU feature detection procedure. The results are cached and
future calls simply return the cached values.

The feature detection procedure is as follows:

1. Set the bit for each supported feature (that is, start by assuming all
supported CPU features are available).

1. For each supported feature, register an exception handler with the
enclave's trusted runtime library (**sgx_register_exception_handler** if built
for the Intel SGX SDK, and **oe_add_vectored_exception_handler** if built
for the Microsoft Open Enclave SDK).

1. Save the state of any registers that will be modified in step 4.

1. Execute an instruction that is unique to the feature that is being probed.

1. Restore the original value of any modified registers.

If the exception handler **is not** called, then the feature is supported.

If the handler **is** called, execute the following sequence:

1. Verify that the exception was generated by a #UD fault. If not, pass the exception to the next handler in the chain.

2. Verify that the fault matches the instruction for the feature being probed. If not, pass the exception to the next handler in the chain.

3. Clear the bit corresponding to that feature, indicating the
feature is not available on the CPU.

4. Skip over the unsupported instruction by advancing the instruction pointer.

The library will automatically clear bits for features if their prerequisite features are not detected. For example, the AVX2 feature is an extension of AVX; if AVX is not present then AVX2 does not need to be checked and its feature bit can be cleared.

## API

#define <sgx_tcpu_features.h>

**int sgx_cpuid_features_merge(int** _info[4]_, **int** _leaf_**)**

**int sgx_cpuidex_features_merge(int** _info[4]_, **int** _leaf_, **int**  _subleaf_**)**

**int sgx_cpu_features(int** _info[4]_, **int** _leaf_, **int** _subleaf_**)**

**int sgx_cpu_features_mask(int** _info[4]_, **int** _leaf_, **int**  _subleaf_**)**

These functions perform runtime detection of CPU features and feature families without exiting the enclave to untrusted space:

**int sgx_cpuid_features_merge** and **int sgx_cpuidex_features_merge** take
CPUID bitfields for EAX, EBX, ECX, and EDX stored in _info_ for a given
_leaf_ and _subleaf_, probes for CPU features in that _leaf_ and _subleaf_, and
then **replaces** the bits in _info_ with bits from the trusted CPU feature
detection. The values in _info_ are modified by these functions.

Internally, these functions call **sgx_cpu_features_mask** to zero out
bits of the CPU features that it probes for, calls **sgx_cpu_features**
to obtain the detected feature bits, then ORs the two together. A
simplified version of this routine is:

```
sgx_cpu_features_mask(mask, leaf, subleaf);
sgx_cpu_features(info, leaf, subleaf);

for (i= 0; i< 4; ++i) {
  cpuinfo[i]&= ~mask[i];
  cpuinfo[i]|= info[i];
}
```

Note that **sgx_cpuid_features_merge** is implemented as a macro:

```
#define sgx_cpuid_features_merge(i,l) sgx_cpuidex_features_merge(i,l,0)
```

If the _leaf_ and _subleaf_ values do not correspond to supported CPUID
feature bits then these functions are essentially a no-op, and the original
vlaue of _info_ is unchanged.

**sgx_cpu_features** performs a trusted CPU feature detection for
features correspnding to a given _leaf_ and _subleaf_. It returns a bitfield
for EAX, EBX, ECX, and EDX in _info_ corresponding to the features that
were detected. **Note that this does not call CPUID, and only sets bits
corresponding to features that this library explicitly probes for.** It is
thus not a general replacement for CPUID.

**sgx_cpu_features_mask** returns the feature bits that the library supports
for a given _leaf_ and _subleaf_. EAX, EBX, ECX, and EDX are represented by
info.

In short, **sgx_cpu_features_mask** tells you what features the library
probes for, and **sgx_cpud_features** returns the features that are actually
found. These latter two are low-level functions, and most developers
would probably want to call one of the _merge_ functions instead.

### Return Values

**sgx_cpu_features** and **sgx_cpu_features_mask** return
**SGX_TCPUID_OK** if the _leaf_ and _subleaf_ correspond to CPUID feature
bits that the library supports.

A return value of
**SGX_TCPUID_UNSUPPORTEDLEAF** means that _leaf_ and
_subleaf_ do not correspond to CPUID-detected features that this
library supports. This return value is not necessarily an error.

**sgx_cpuid_features_merge** and **sgx_cpuidex_features_merge** return
**SGX_TCPUID_OK** on success. Note that attempting to merge CPUID
values from an unsupported _leaf_ and _subleaf_  is still considered a
success, and is effecitvely a no-op.

Any other value is an error, though at the current time these functions
never fail.
