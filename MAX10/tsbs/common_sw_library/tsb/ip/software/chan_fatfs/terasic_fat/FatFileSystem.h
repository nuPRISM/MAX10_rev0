// --------------------------------------------------------------------
// Copyright (c) 2007 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------

#ifndef FATFILESYSTEM_H_
#define FATFILESYSTEM_H_

#include "FatConfig.h"

typedef void *FAT_HANDLE;
typedef void *FAT_FILE_HANDLE;
typedef void *DEVICE_HANDLE;
#define MAX_FILENAME_LENGTH 256

#define fat_packed __attribute__ ((packed,aligned(1)))


typedef enum{
    FAT_SD_CARD=0,
    FAT_USB_DISK,
}FAT_DEVICE;

typedef enum{
    FILE_SEEK_BEGIN,
    FILE_SEEK_CURRENT,
    FILE_SEEK_END
}FAT_SEEK_POS;





typedef struct{
    // my ext
    char szName[MAX_FILENAME_LENGTH];  // long-filename
    terasic_bool bLongFilename;
    terasic_bool bFile;
    terasic_bool bDirectory;
    terasic_bool bVolume;
    //
    char Attribute;
    unsigned short CreateTime;
    unsigned short CreateDate;
    unsigned short LastAccessDate;
    unsigned short FirstLogicalClusterHi; // not used in FAT12/FAT16
    unsigned short LastWriteTime;
    unsigned short LastWriteDate;
    unsigned short FirstLogicalCluster;
    unsigned int FileSize;    
}FILE_CONTEXT;



typedef struct{
    unsigned int DirectoryIndex;
    FAT_HANDLE   hFat;
}FAT_BROWSE_HANDLE;

typedef struct{
    char szName[256];
    char szExt[8];
    unsigned int nFileSize;
}FILE_INFO;





// Device Mount/Unmount
FAT_HANDLE Fat_Mount(FAT_DEVICE FatDevice, DEVICE_HANDLE hDevice);
void Fat_Unmount(FAT_HANDLE Fat);

// FAT Browse
unsigned int Fat_FileCount(FAT_HANDLE Fat);
terasic_bool Fat_FileBrowseBegin(FAT_HANDLE hFat, FAT_BROWSE_HANDLE *pFatBrowseHandle);
terasic_bool Fat_FileBrowseNext(FAT_BROWSE_HANDLE *pFatBrowseHandle, FILE_CONTEXT *pFileContext);
terasic_bool Fat_DumpFilename(char *pFilename, terasic_bool bLongFilename);



// File Access
FAT_FILE_HANDLE Fat_FileOpen(FAT_HANDLE Fat, const char *pFilename);
unsigned int Fat_FileSize(FAT_FILE_HANDLE hFileHandle);
terasic_bool Fat_FileRead(FAT_FILE_HANDLE hFileHandle, void *pBuffer, const int nBufferSize);
terasic_bool Fat_FileSeek(FAT_FILE_HANDLE hFileHandle, const FAT_SEEK_POS SeekPos, const int nOffset);
void Fat_FileClose(FAT_FILE_HANDLE hFileHandle);
terasic_bool Fat_FileIsOpened(FAT_FILE_HANDLE hFileHandle);

//
float Fat_SpeedTest(FAT_HANDLE hFat, alt_u32 TestDurInMs);



#endif /*FATFILESYSTEM_H_*/
