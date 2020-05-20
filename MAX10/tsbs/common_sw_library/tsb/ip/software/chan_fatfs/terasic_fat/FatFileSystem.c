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
// History:
//     03/05/2008
//        1. bug fix for the function fatComposeShortFilename
//     01/10/2008
//        1.add "vol_id" detect for filename
//        2.add long filename support
//        3.add byte_per_sector=512 limitation 
//     11/200/2007, richard bug fix, Cluster is not inited in Fat_FileRead

#include <string.h> // memcpy
#include "../terasic_lib/terasic_includes.h"
#include "FatFileSystem.h"
#include "FatInternal.h"

int dummy_debug22;
