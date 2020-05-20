#ifndef HDMI_MAIN_H
#define HDMI_MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

extern int hdmi_tx_ready;
int hdmi_main();
void hdmi_check_connection();

#ifdef __cplusplus
}
#endif

#endif
