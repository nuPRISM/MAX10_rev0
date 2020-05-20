@echo on
set scripts_pwd=%CD%
C:
cd /
cd %XILINX_TOOLS_PATH%/..
REM Copyright (c) 1995-2012 Xilinx, Inc.  All rights reserved.
REM Set current working directory
set XIL_SCRIPT_LOC=%CD%
REM Remove trailing slash
set XIL_SCRIPT_LOC=%XIL_SCRIPT_LOC%
REM Call settings file for each product
set xlnxInstLocList=
set xlnxInstLocList=%xlnxInstLocList% common
set xlnxInstLocList=%xlnxInstLocList% EDK
set xlnxInstLocList=%xlnxInstLocList% common/CodeSourcery
set xlnxInstLocList=%xlnxInstLocList% PlanAhead
set xlnxInstLocList=%xlnxInstLocList% ISE
set xlnxInstLocList=%xlnxInstLocList% ../../Vivado/2012.4
for %%d in (%xlnxInstLocList%) do (
	if EXIST %XIL_SCRIPT_LOC%\%%d\.settings64.bat (
		call %XIL_SCRIPT_LOC%\%%d\.settings64.bat
	)
)
REM Unset XIL_SCRIPT_LOC
set XIL_SCRIPT_LOC=
REM Execute command if any
if "%1" neq "" (
   if /i "%~x1" == ".bat" (
      call %*
   ) else (
      start %*
   )
)
REM Unset xlnxInstLocList
set xlnxInstLocList=
cd %scripts_pwd%
cd ../../../tsbs/fmc1/tsb/ip/rtl/workspace/adc_fmc_mcs_ctrl/Debug
make clean
make
cd %scripts_pwd%
exit