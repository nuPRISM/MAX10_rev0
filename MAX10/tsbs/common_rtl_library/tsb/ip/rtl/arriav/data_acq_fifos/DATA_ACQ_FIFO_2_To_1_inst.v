DATA_ACQ_FIFO_2_To_1	DATA_ACQ_FIFO_2_To_1_inst (
	.data ( data_sig ),
	.rdclk ( rdclk_sig ),
	.rdreq ( rdreq_sig ),
	.wrclk ( wrclk_sig ),
	.wrreq ( wrreq_sig ),
	.q ( q_sig ),
	.rdempty ( rdempty_sig ),
	.rdfull ( rdfull_sig ),
	.wrempty ( wrempty_sig ),
	.wrfull ( wrfull_sig ),
	.wrusedw ( wrusedw_sig )
	);
