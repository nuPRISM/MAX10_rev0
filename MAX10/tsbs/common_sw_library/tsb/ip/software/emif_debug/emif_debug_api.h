// Example program for using the Altera EMIF On-Chip Debug Port
// Quartus Version: 17.0std
#include "emif_export.h"

// Sends a command to the EMIF
alt_32 send_command(volatile debug_data_t* debug_data_ptr, alt_32 command, alt_32 args[], alt_32 num_args);

int emif_complete_status_report();