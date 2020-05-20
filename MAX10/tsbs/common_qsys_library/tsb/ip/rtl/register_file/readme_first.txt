Avalon Memory-Mapped Slave Template Design Example v2.0

This file contains the following sections:

o  Project Directory Names	
o  Overview
o  Installation Information
o  Using the Slave Template 2.0	
o  Revision History	
o  Disclaimer	
o  Contacting Altera		


Project Directory Names
===================

When you extract the archive, the following folder structure will be created:

<de_niosII_avalon_mm_slave_template>
|--- <v1_0>
     |--- <ip>
          |--- <Slave_Template>
               |--- ALTERA_LOGO_ANIM.gif
               |--- slave_template_hw.tcl
               |--- slave_template.v
|--- <v2_0>
     |--- <ip>
          |--- <Slave_Template>
               |--- slave_template_hw.tcl
               |--- slave_template.v
               |--- interrupt_logic.v
               |--- slave_template_macros.h
|--- Avalon_MM_Slave_Readme_v1_0.pdf
|--- readme_first.txt (this file)


Overview
========

This readme file desribes the version 2.0 of slave template design example. For information on version 1.0, please refer to Avalon_MM_Slave_Readme_v1_0.pdf 

Provided in this package is a slave template that you can use to make your own custom logic accessible from within SOPC Builder. Signals are exposed at the top of the system so that you can connect them to your custom logic. You can also use the HDL provided in the template to add new capabilities to an existing SOPC Builder component. The component provides the following functionality:

• Pipelined read and write capabilities
• Up to 16 individual read and write registers
• Optional output loopback mode to make outputs readable to software
• Data widths of 8, 16, and 32
• Optional synchronization logic that you can use for handshaking purposes with your own custom hardware
• Support read with interrupt capabilities
• Support interrupt's edge capture registers individual bit-clearing


Installation Information
==================

In order to use the templates, simply copy the ‘ip’ directory into your own hardware project directory. SOPC Builder references the ip directory by default. When you open SOPC Builder the slave template will appear in the component listing on the left side of the SOPC Builder user interface. The templates will appear in the group called “Templates”. You will be asked to setup parameters such as the data width and others while  adding the slave template to the system.


Using the Slave Template 2.0
======================

This section describes how to use the interrupt functionality of the slave template 2.0.

Slave Template 2.0 Register Map
-------------------------------------------------

For a specific register file, the register map is as follow:

Offset    Register Name           Descriptions
0           Read Register File      User input to the slave template
1           Write Register File      Output from slave template to user
2           Interrupt Mask            Enable/disable interrupt
3           Edge Capture             Capture rising edge on user input data. Write to this register to clear interrupt (support bit-clearing)

The register files numbering convention is as follow:
Register File 0  0x0
Register File 1  0x1
Register File 2  0x2
Register File 3  0x3
Register File 4  0x4
Register File 5  0x5
Register File 6  0x6
Register File 7  0x7
Register File 8  0x8
Register File 9  0x9
Register File 10  0xA
Register File 11  0xB
Register File 12  0xC
Register File 13  0xD
Register File 14  0xE
Register File 15  0xF
Prioritized Interrupt Source 0x100 (for description, refer to Determining Interrupt Source section below)

Let's take Register File 0 as example, the complete register map for it will be:
Read register file 0   0x00
Write register file 0   0x01
Interrupt mask 0       0x02
Edge capture 0        0x03

For complete registers offset list, refer to slave_template_macros.h C-header file. Altera recommends using these macros in your software.


Enabling Interrupt
--------------------------

To turn on interrupt feature of this component, in the slave template GUI while you adding it in SOPC Builder, select Enabled under Interrupt Capabilities option. This option is available for setting only when you have chosen at least one of the Register Capabilities as Read Only or Write/Read.

Next, you should enable the interrupt in software by writing to the interrupt mask registers. Setting the bits of that register to 1s enables the interrupt generation.


Determining Interrupt Source
---------------------------------------------

In order to know which register file and spefically which bits cause the interrupt, you should read Prioritized Interrupt Source (PIS) register when interrupt occurs. This register tells you which register file caused the interrupt generation. For example: PIS register value is 1 for interrupt caused by Register File 0, while 2 is for Register File 1 and so on. When there is no interrupt happen, this register will have value of zero.

Interrupts caused by multiple simultaneous register files are prioritized. Register File 0 has the highest interrupt priority while Register File 15 has the lowest. When this happens, you should clear the highest interrupt so that the lower interrupts are served later. 


Example Interrupt Service Rountine (ISR)
-------------------------------------------------------------

This is an example ISR where it checks which interrupt sources caused the interrupt, save the edge capture register value, and clear interrupt.

char which_reg_file;
char edge_capture_ptr;

/******************************************ISR**********************************************************************/
void my_isr(void* context, alt_u32 id)
{        
    //check which register file causes interrupt
    which_reg_file = IORD_8DIRECT(SLAVE_TEMPLATE_BASE, PRIORITIZED_INTERRUPT_SRC);         
            
    //store the edge capture register value
    edge_capture_ptr = IORD_8DIRECT(SLAVE_TEMPLATE_BASE, (((which_reg_file - 1)<<4) + 3));    
        
    //clear the interrupt
    IOWR_8DIRECT(SLAVE_TEMPLATE_BASE, (((which_reg_file - 1)<<4) + 3), 0xFF);    
}
/********************************************************************************************************************/


Revision history
=============

Version 1.0
------------------

Initial release.


Version 2.0
------------------

Add interrupt capabilities to the read register files.


Disclaimer
=========

These component templates may be used within Altera® devices only and remain the property of Altera. They are being provided on an "as-is" basis and as an accommodation, and therefore all warranties, representations, or guarantees of any kind (whether express, implied or statutory) including, without limitation, warranties of merchantability, non-infringement, or fitness for a particular purpose, are specifically disclaimed. Altera expressly does not recommend, suggest, or require that these examples be used in combination with any other product not provided by Altera.


Contacting Altera
=============

Although we have made every effort to ensure that this version of the Avalon MM Slave Template design works correctly, there may be problems that we have not encountered. If you have a question or problem that is not answered by the information provided in this readme file, please contact your Altera Field Applications Engineer.

If you have additional questions that are not answered in the documentation provided with this design, contact Altera Applications using one of the following methods:

Technical Support Hotline:  (800) 800-EPLD (U.S.)
                            (408) 544-7000 (Internationally)
World wide web:             http://www.altera.com/mysupport

Last updated September, 2009
Copyright © 2009 Altera Corporation. All rights reserved.

