#ifndef HDMI_MAIN_H
#define HDMI_MAIN_H

#ifdef __cplusplus
extern "C" {
#endif

extern int hdmi_tx_ready;
void hdmi_main_process(void *pd);

#ifdef __cplusplus
}
#endif

#endif
