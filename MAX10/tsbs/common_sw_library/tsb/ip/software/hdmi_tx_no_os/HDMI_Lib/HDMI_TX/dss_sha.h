#ifndef _DSS_SHA_H_
#define _DSS_SHA_H_

#ifdef SUPPORT_DSSSHA
typedef USHORT *LongNumber;

struct dss_key {
	LongNumber p,q,g,y,x;
};

typedef struct {
	ULONG h[5];
	BYTE block[64];
	LONG blkused;
	ULONG lenhi,lenlo;
} SHA_State;

#ifdef _DSS_SHA_
        // SRM Tables
    #if 0
        _CODE BYTE SRM0[] = {
        	0x80,0x00,0x00,0x02,// version
        	0x00,0x00,0x00,0x31,// length
        	0x01,// number of keys
        	0x86,0x88,0x4d,0x5d,0x9f,// key of Sony Wega KV-30HS420
        	// invalid DSS signature
        	0xe3,0x17,0xe6,0x46,0x6e,0xc3,0xef,0xbd,
        	0x4c,0xca,0x0d,0x4f,0x76,0x2a,0x15,0x96,
        	0xce,0x62,0x22,0x2b,0xe5,0xc9,0xa3,0x72,
        	0xef,0x26,0x76,0xcf,0x30,0x50,0x4e,0x55,
        	0x59,0x9e,0x79,0xc3,0x36,0xe1,0xaa,0xfd,
        };
    #endif
    #if 1
        _CODE BYTE SRM1[] = {
        	0x80,0x00,0x00,0x01,// version
        	0x00,0x00,0x00,0x2b,// length
        	// no keys
        	// "DCP LLC" production DSS signature
        	0xd2,0x48,0x9e,0x49,0xd0,0x57,0xae,0x31,
        	0x5b,0x1a,0xbc,0xe0,0x0e,0x4f,0x6b,0x92,
        	0xa6,0xba,0x03,0x3b,0x98,0xcc,0xed,0x4a,
        	0x97,0x8f,0x5d,0xd2,0x27,0x29,0x25,0x19,
        	0xa5,0xd5,0xf0,0x5d,0x5e,0x56,0x3d,0x0e
        };
    #endif
    #if 0
        _CODE BYTE SRM2[] = {
        	0x80,0x00,0x00,0x02,// version
        	0x00,0x00,0x00,0x31,// length
        	0x01,// number of keys
        	0x51,0x1e,0xf2,0x1a,0xcd,// key
        	// "facsimile" DSS signature
        	0xe3,0x17,0xe6,0x46,0x6e,0xc3,0xef,0xbd,
        	0x4c,0xca,0x0d,0x4f,0x76,0x2a,0x15,0x96,
        	0xce,0x62,0x22,0x2b,0xe5,0xc9,0xa3,0x72,
        	0xef,0x26,0x76,0xcf,0x30,0x50,0x4e,0x55,
        	0x59,0x9e,0x79,0xc3,0x36,0xe1,0xaa,0xfd,
        };
    #endif
    #if 0
        _CODE BYTE SRM3[] = {
        	0x80,0x00,0x00,0x03,// version
        	0x00,0x00,0x00,0x31,// length
        	0x01,// number of keys
        	0xe7,0x26,0x97,0xf4,0x01,// key
        	// "facsimile" DSS signature
        	0xdd,0x1f,0x00,0x30,0x37,0x0d,0x0b,0x54,
        	0xff,0x91,0x02,0xbb,0x07,0x9e,0x48,0x3c,
        	0xfe,0x58,0x9b,0xfc,0x74,0x57,0xb7,0x25,
        	0x67,0xdd,0x72,0xc2,0x55,0xe4,0x1a,0xed,
        	0x99,0x09,0x47,0xb8,0x24,0x21,0x85,0xcc,
        };
    #endif
    #if 0
        _CODE BYTE SRM4[] = {
        	0x80,0x00,0x00,0x04,// version
        	0x00,0x00,0x00,0x36,// length
        	0x02,// number of keys
        	0x51,0x1e,0xf2,0x1a,0xcd,// key
        	0xe7,0x26,0x97,0xf4,0x01,// key
        	// "facsimile" DSS signature
        	0x7a,0xdf,0x4f,0xd5,0x66,0xe0,0x19,0xeb,
        	0x4e,0xd3,0xe0,0x1c,0x1a,0xb3,0xc2,0x8d,
        	0xec,0x8b,0xe8,0x7f,0x9d,0xc0,0x01,0x2d,
        	0x1b,0xda,0xc8,0x30,0xd8,0x30,0x05,0xa0,
        	0x66,0x1d,0x2d,0x26,0x25,0x0d,0x20,0x66,
        };
    #endif
#else
// SRM Tables
    #if 0
        extern _CODE BYTE SRM0[] ;
    #endif
    #if 1
        extern _CODE BYTE SRM1[] ;
    #endif
    #if 0
        extern _CODE BYTE SRM2[] ;
    #endif
    #if 0
        extern _CODE BYTE SRM3[] ;
    #endif
    #if 0
        extern _CODE BYTE SRM4[] ;
    #endif
#endif
//////////////////////////////////////////////////////////////////////
// Function Prototype
//////////////////////////////////////////////////////////////////////

void SHA_Init(SHA_State * s);
void SHA_Bytes(SHA_State * s,void *p,LONG len);
void SHA_Final(SHA_State * s,BYTE *output);
void SHA_Simple(void *p,LONG len,BYTE *output);
void SHATransform(ULONG * digest,ULONG * uData);

LongNumber ln_copy(LongNumber b);
void ln_free(LongNumber b);
LongNumber modpow(LongNumber base,LongNumber exp,LongNumber mod);
LongNumber modmul(LongNumber a,LongNumber b,LongNumber mod);
LongNumber ln_from_bytes(BYTE *uData,LONG nbytes);
LongNumber ln_mul_add(LongNumber a,LongNumber b,LongNumber addend);
LongNumber modinv(LongNumber number,LongNumber modulus);
LONG ln_cmp(LongNumber a,LongNumber b);

SYS_STATUS HDCP_VerifyRevocationList(BYTE *pSRM,BYTE *pBKSV,BYTE *revoked) ;

#endif // SUPPORT_DSSSHA

#endif // _DSS_SHA_H_
