`timescale 1ns / 10ps
`default_nettype none
`include "transacttions.sv"
`include "checker.sv"

module checker_DUT();
	parameter drvrs = 4;
	parameter pckg_sz = 16;

	
	checker_p #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mi_chkr;

	bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
	bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;
	sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;


//	drvr_chkr_mbx = new();	
//	mntr_chkr_mbx = new();
//	mi_chkr = new();

	bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) trans [8];

//	mi_chkr.drvr_chkr_mbx = drvr_chkr_mbx;
//	mi_chkr.mntr_chkr_mbx = mntr_chkr_mbx;

//	trans[0] = new(.dto(16'h00_FF), .tmp(5));
//	trans[1] = new(.dto(16'h01_AB), .tmp(10));	
//	trans[2] = new(.dto(16'h02_CC), .tmp(15));
//	trans[3] = new(.dto(16'h00_DA), .tmp(20));
//	trans[4] = new(.dto(16'h00_FF), .tmp(40), .tpo(lectura));
//	trans[5] = new(.dto(16'h01_AB), .tmp(45), .tpo(lectura));
//	trans[6] = new(.dto(16'h02_CC), .tmp(50), .tpo(lectura));
//	trans[7] = new(.dto(16'h00_DA), .tmp(55), .tpo(lectura));
	
	initial begin

		drvr_chkr_mbx = new();	
		mntr_chkr_mbx = new();
		chkr_sb_mbx = new();
		mi_chkr = new();
		mi_chkr.drvr_chkr_mbx = drvr_chkr_mbx;
		mi_chkr.mntr_chkr_mbx = mntr_chkr_mbx;
		mi_chkr.chkr_sb_mbx = chkr_sb_mbx;


		trans[0] = new(.dto(16'h00_FF), .tmp(5));
		trans[1] = new(.dto(16'h01_AB), .tmp(10));	
		trans[2] = new(.dto(16'h02_CC), .tmp(15));
		trans[3] = new(.dto(16'h00_DA), .tmp(20));
		trans[4] = new(.dto(16'h00_FF), .tmp(40), .tpo(lectura));
		trans[5] = new(.dto(16'h01_AB), .tmp(45), .tpo(lectura));
		trans[6] = new(.dto(16'h02_CC), .tmp(50), .tpo(lectura));
		trans[7] = new(.dto(16'h00_DA), .tmp(55), .tpo(lectura));
		#10;
		drvr_chkr_mbx.put(trans[0]);
		#1;
		drvr_chkr_mbx.put(trans[1]);
		#1;
		drvr_chkr_mbx.put(trans[2]);
		#1;
		drvr_chkr_mbx.put(trans[3]);
		#1;
		mntr_chkr_mbx.put(trans[4]);
		#1;
		mntr_chkr_mbx.put(trans[5]);
		#1;
		mntr_chkr_mbx.put(trans[6]);
		#1;
		mntr_chkr_mbx.put(trans[7]);
		#1;
		
		
		fork
			mi_chkr.update();
			mi_chkr.check();
		join_none

	end


	


endmodule
