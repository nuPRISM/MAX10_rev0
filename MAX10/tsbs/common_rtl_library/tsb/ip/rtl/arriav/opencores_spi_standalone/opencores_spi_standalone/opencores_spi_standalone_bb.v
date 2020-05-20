
module opencores_spi_standalone (
	avalon_mm_slave_address,
	avalon_mm_slave_read,
	avalon_mm_slave_readdata,
	avalon_mm_slave_write,
	avalon_mm_slave_writedata,
	avalon_mm_slave_waitrequest,
	clk_clk,
	opencores_spi_miso_pad_i,
	opencores_spi_mosi_pad_o,
	opencores_spi_sclk_pad_o,
	opencores_spi_ss_pad_o,
	opencores_spi_tx_bit_pos,
	opencores_spi_rx_bit_pos,
	opencores_spi_cnt,
	opencores_spi_wb_err_o,
	opencores_spi_wb_cyc_i,
	opencores_spi_currently_active_export,
	opencores_spi_debug_wb_clk_i,
	opencores_spi_debug_wb_rst_i,
	opencores_spi_debug_wb_adr_i,
	opencores_spi_debug_wb_dat_i,
	opencores_spi_debug_wb_dat_o,
	opencores_spi_debug_wb_sel_i,
	opencores_spi_debug_wb_we_i,
	opencores_spi_debug_wb_stb_i,
	opencores_spi_debug_wb_cyc_i,
	opencores_spi_debug_wb_ack_o,
	opencores_spi_debug_wb_err_o,
	opencores_spi_debug_wb_int_o,
	opencores_spi_debug_divider,
	opencores_spi_debug_ctrl,
	opencores_spi_debug_ss,
	opencores_spi_debug_wb_dat,
	opencores_spi_debug_tag_word_in,
	opencores_spi_debug_tag_word_out,
	opencores_spi_debug_tag_word_export,
	opencores_spi_interrupt_sender_irq,
	opencores_spi_manual_reset_out_export,
	opencores_spi_sdio_helper_export,
	reset_reset_n,
	opencores_spi_aux_control_out_export,
	opencores_spi_aux_control_in_export);	

	input	[31:0]	avalon_mm_slave_address;
	input		avalon_mm_slave_read;
	output	[31:0]	avalon_mm_slave_readdata;
	input		avalon_mm_slave_write;
	input	[31:0]	avalon_mm_slave_writedata;
	output		avalon_mm_slave_waitrequest;
	input		clk_clk;
	input		opencores_spi_miso_pad_i;
	output		opencores_spi_mosi_pad_o;
	output		opencores_spi_sclk_pad_o;
	output	[7:0]	opencores_spi_ss_pad_o;
	output	[7:0]	opencores_spi_tx_bit_pos;
	output	[7:0]	opencores_spi_rx_bit_pos;
	output	[7:0]	opencores_spi_cnt;
	output		opencores_spi_wb_err_o;
	input		opencores_spi_wb_cyc_i;
	output		opencores_spi_currently_active_export;
	output		opencores_spi_debug_wb_clk_i;
	output		opencores_spi_debug_wb_rst_i;
	output	[4:0]	opencores_spi_debug_wb_adr_i;
	output	[31:0]	opencores_spi_debug_wb_dat_i;
	output	[31:0]	opencores_spi_debug_wb_dat_o;
	output	[3:0]	opencores_spi_debug_wb_sel_i;
	output		opencores_spi_debug_wb_we_i;
	output		opencores_spi_debug_wb_stb_i;
	output		opencores_spi_debug_wb_cyc_i;
	output		opencores_spi_debug_wb_ack_o;
	output		opencores_spi_debug_wb_err_o;
	output		opencores_spi_debug_wb_int_o;
	output	[15:0]	opencores_spi_debug_divider;
	output	[13:0]	opencores_spi_debug_ctrl;
	output	[7:0]	opencores_spi_debug_ss;
	output	[31:0]	opencores_spi_debug_wb_dat;
	input	[7:0]	opencores_spi_debug_tag_word_in;
	output	[7:0]	opencores_spi_debug_tag_word_out;
	output	[7:0]	opencores_spi_debug_tag_word_export;
	output		opencores_spi_interrupt_sender_irq;
	output	[7:0]	opencores_spi_manual_reset_out_export;
	output	[7:0]	opencores_spi_sdio_helper_export;
	input		reset_reset_n;
	output	[31:0]	opencores_spi_aux_control_out_export;
	input	[31:0]	opencores_spi_aux_control_in_export;
endmodule
