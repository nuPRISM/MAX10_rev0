#!/bin/bash
SCRIPTS_PWD=$(pwd)
echo "SCRIPTS_PWD = " $SCRIPTS_PWD
SCRIPTS_PWD=`cygpath -w $SCRIPTS_PWD`
echo "SCRIPTS_PWD = " $SCRIPTS_PWD
corrected_pwd=`echo $SCRIPTS_PWD | tr '\\' '/'`
echo "corrected_pwd =" $corrected_pwd

ip_addr=''
logfile=''
emulation_file=''
phy_to_use=''
usb=''
nios_to_use=''
use_as_relay=''
silent_mode=''
verbose_mode=''
port_to_use=''

for i in "$@"
do
echo "parameter is " $i
case $i in
    -i=*|--ipaddr=*)
    ip_addr=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
	
	--relayport=*)
    port_to_use=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
	
    -u=*|--usb=*)
    usb=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
    
	-l=*|--log=*)
    logfile=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
	
	-e=*|--emulate=*)
    emulation_file=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
	
	-p=*|--phy=*)
    phy_to_use=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
	
	-n=*|--nios=*)
    nios_to_use=`echo $i | sed 's/[-a-zA-Z0-9\.]*=//'`
    ;;
	
	-r|--relay)
    use_as_relay=1
    ;;
	
	-s|--silent)
    silent_mode=1
    ;;
	
	-v|--verbose)
    verbose_mode=1
    ;;
	
	--default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
done

if [ -z $ip_addr ]
then
    export system_console_comm_method=usb
    echo "did not find ip address"
    env --unset=system_console_ip_addr_of_card_server
else
    export system_console_comm_method=ethernet
    echo found IP addr for server: ${ip_addr}
    export system_console_ip_addr_of_card_server=${ip_addr}
fi

if [ -z $usb ]
then
     echo did not find usb cable number, setting 0 as default    
	 export system_console_usb_cable_of_card_server=0
else
    export system_console_usb_cable_of_card_server=${usb}
	echo found USB cable number for server: ${usb}
fi

if [ -z $logfile ]
then
     echo "did not find logfile"
 	 export system_console_use_logfile=0

	  env --unset=system_console_logfile_name
else
     echo "will log to: " ${logfile}
	 export system_console_use_logfile=1
     export system_console_logfile_name=${logfile}
fi

if [ -z $emulation_file ]
then
     echo "did not find emulation_file"
 	 export system_console_use_emulation_file=0
	 env --unset=system_console_emulation_filename
else
     echo "will emulate from: " ${emulation_file}
	 export system_console_use_emulation_file=1
     export system_console_emulation_filename=${emulation_file}
fi

if [ -z $phy_to_use ] 
then
     echo "did not find request to use Jtag-to-Avalon PHY"
	 export system_console_use_jtag_to_avalon_phy=0
	 env --unset=system_console_jtag_to_avalon_phy_to_use
else
     echo "Found request to use Jtag-to-Avalon PHY: phy-" ${phy_to_use}
	 export system_console_use_jtag_to_avalon_phy=1
	 export system_console_jtag_to_avalon_phy_to_use=${phy_to_use};
fi

if [ -z $nios_to_use ] 
then
     echo "Did not find request to use specific nios for USB comm, setting nios to use to 0"
	 export system_console_nios_to_use=0
else
     echo "Found request to use nios core " ${nios_to_use} " for USB comm"
	 export system_console_nios_to_use=${nios_to_use};
fi

if [ -z $use_as_relay ] 
then
     echo "Did not find request to use DASHING as relay"
	 export system_console_is_ethernet_relay_only=0
else
     echo "Found request to use DASHING as relay"
	 export system_console_is_ethernet_relay_only=1;
fi

if [ -z $verbose_mode ] 
then
     echo "Did not find request to make Ethernet Relay verbose"
	 export system_console_ethernet_relay_is_verbose=0
else
     echo "Found request to make Ethernet Relay verbose"
	 export system_console_ethernet_relay_is_verbose=1;
fi
if [ -z $port_to_use ] 
then
     echo "Did not find request to use nonstandard port"
	 export system_console_ethernet_use_nonstandard_port=0
	 
else
     echo "Found request to use nonstandard port of " ${port_to_use} " for communications"
	 export system_console_ethernet_use_nonstandard_port=1;
	 export system_console_ethernet_port_to_use=${port_to_use};
fi

export system_console_directory_called_from=${corrected_pwd}
echo "Called from : " ${corrected_pwd}
echo IP_ADDR = ${ip_addr}
echo USB = ${usb}

if [ -z $silent_mode ] 
then
	$SOPC_KIT_NIOS2/../quartus/sopc_builder/bin/system-console -disable_timeout --rc_script=local_system_console_rc_script.tcl -debug --desktop_script="dashing_gui.tcl"
else
	$SOPC_KIT_NIOS2/../quartus/sopc_builder/bin/system-console -disable_timeout --rc_script=local_system_console_rc_script.tcl --script="../../../tsbs/dashing/tsb/ip/scripts/dashing_gui.tcl" --cli --debug
fi