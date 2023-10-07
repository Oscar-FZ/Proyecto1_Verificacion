`timescale 1ns/10ps
`default_nettype none
`include "transacttions.sv"
`include "score_board.sv"

module scoreboard_DUT();
	parameter drvrs = 4;
	parameter pckg_sz = 16;

	score_board #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mi_sb;

	sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;

	sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) trans [2];

	initial begin
		chkr_sb_mbx = new();

		mi_sb = new();
		trans[0] = new();
		trans[1] = new();
		mi_sb.chkr_sb_mbx = chkr_sb_mbx;

		trans[0].dato_enviado =16'h00AB;
		trans[0].tiempo_push =20;
		trans[0].tiempo_pop =12;
		trans[0].completado =1;
		trans[0].latencia =8;
		trans[0].dsp_env = 8'h01;
		trans[0].dsp_rec = 8'h00;

		trans[1].dato_enviado =16'h01FF;
		trans[1].tiempo_push =24;
		trans[1].tiempo_pop =16;
		trans[1].completado =1;
		trans[1].latencia =8;
		trans[1].dsp_env = 8'h02;
		trans[1].dsp_rec = 8'h01;

		chkr_sb_mbx.put(trans[0]);
		#1;
		chkr_sb_mbx.put(trans[1]);

		mi_sb.run();


	end

endmodule
