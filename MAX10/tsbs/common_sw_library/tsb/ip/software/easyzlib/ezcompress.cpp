#include "easyzlib.h"

#define EZ_CHECKLENGTH 8192

int ezcompress( ezbuffer& bufDest, const ezbuffer& bufSrc )
{
	if ( bufDest.nLen == 0 )
		bufDest.Alloc( EZ_CHECKLENGTH );
	int nErr = ezcompress( bufDest.pBuf, &bufDest.nLen, bufSrc.pBuf, bufSrc.nLen );
	if ( nErr == EZ_BUF_ERROR )
	{
		bufDest.Alloc( bufDest.nLen );
		nErr = ezcompress( bufDest.pBuf, &bufDest.nLen, bufSrc.pBuf, bufSrc.nLen );
	}
	return nErr;
};

int ezuncompress( ezbuffer& bufDest, const ezbuffer& bufSrc )
{
	if ( bufDest.nLen == 0 )
		bufDest.Alloc( EZ_CHECKLENGTH );
	int nErr = ezuncompress( bufDest.pBuf, &bufDest.nLen, bufSrc.pBuf, bufSrc.nLen );
	if ( nErr == EZ_BUF_ERROR )
	{
		bufDest.Alloc( bufDest.nLen );
		nErr = ezuncompress( bufDest.pBuf, &bufDest.nLen, bufSrc.pBuf, bufSrc.nLen );
	}
	return nErr;
};

#ifdef MCD_STR
/* CMarkup designated string class and macros */

int ezcompress( ezbuffer& bufDest, const MCD_STR& strSrc )
{
	int nSrcLen = MCD_STRLENGTH(strSrc) * sizeof(MCD_CHAR);
	/* alternatively: bufDest.Alloc( EZ_COMPRESSMAXDESTLENGTH(nSrcLen) ); // >.1% + 12 */
	unsigned char pTempDest[EZ_CHECKLENGTH];
	long nTempLen = EZ_CHECKLENGTH;
	int nErr = ezcompress( pTempDest, &nTempLen, (const unsigned char*)MCD_2PCSZ(strSrc), nSrcLen );
	bufDest.Alloc( nTempLen );
	nErr = ezcompress( bufDest.pBuf, &bufDest.nLen, (const unsigned char*)MCD_2PCSZ(strSrc), nSrcLen );
	return nErr;
}

int ezuncompress( MCD_STR& strDest, const ezbuffer& bufSrc )
{
	unsigned char pTempDest[EZ_CHECKLENGTH];
	long nTempLen = EZ_CHECKLENGTH;
	int nErr = ezuncompress( pTempDest, &nTempLen, bufSrc.pBuf, bufSrc.nLen );
	int nDestStrLen = nTempLen / sizeof(MCD_CHAR);
	MCD_CHAR* p = MCD_GETBUFFER(strDest,nDestStrLen);
	nErr = ezuncompress( (unsigned char*)p, &nTempLen, bufSrc.pBuf, bufSrc.nLen );
	MCD_RELEASEBUFFER(strDest,p,nDestStrLen);
	return nErr;
}

#endif /* MCD_STR */