`timescale 1ns / 1ps
`default_nettype none
`include "Library.sv"
`include "transacttions.sv"
`include "driver_monitor.sv"

module DUT_TB();
    parameter WIDTH = 16;
    parameter PERIOD = 2;
    parameter bits = 1;
    parameter drvrs = 4;
    parameter pckg_sz = 16;
    parameter broadcast = {8{1'b1}} ;

    bit CLK_100MHZ;                                     //in
    
    drvr_mntr_hijo #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) driver_UT [drvrs];

    bus_pckg_mbx agnt_drvr_mbx;
    bus_pckg_mbx drvr_chkr_mbx;
    bus_pckg_mbx mntr_chkr_mbx;

    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) trans [8];

    bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) _if (.clk(CLK_100MHZ));
    always #(PERIOD/2) CLK_100MHZ=~CLK_100MHZ;
    
    bs_gnrtr_n_rbtr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) bus_DUT
    (
        .clk    (_if.clk),
        .reset  (_if.reset),
        .pndng  (_if.pndng),
        .push   (_if.push),
        .pop    (_if.pop),
        .D_pop  (_if.D_pop),
        .D_push (_if.D_push)
    );
    
    initial begin
      	CLK_100MHZ = 0;
      	
	agnt_drvr_mbx = new();
	drvr_chkr_mbx = new();
	mntr_chkr_mbx = new();

        $display("INICIO");
        for (int i = 0; i<drvrs; i++) begin
            $display("[%d]", i);
            driver_UT[i] =new(i);
	    driver_UT[i].dm_hijo.vif = _if;
	    driver_UT[i].agnt_drvr_mbx = agnt_drvr_mbx;
	    driver_UT[i].drvr_chkr_mbx = drvr_chkr_mbx;
	    driver_UT[i].mntr_chkr_mbx = mntr_chkr_mbx;
            #1;
        end
	
	trans[0] = new(.dto(16'h01AA));
	trans[1] = new(.dto(16'h00BB));
	trans[2] = new(.dto(16'h03CC));
	trans[3] = new(.dto(16'h02DD));

	agnt_drvr_mbx.put(trans[0]);
	agnt_drvr_mbx.put(trans[1]);
	agnt_drvr_mbx.put(trans[2]);
	agnt_drvr_mbx.put(trans[3]);

	_if.reset = 1;
	#1;
	_if.reset = 0;	
        
	for (int i = 0; i<drvrs; i++) begin
	    fork
		automatic int j = i;
		begin
		    driver_UT[j].run_drvr();
		    driver_UT[j].run_mntr();

		end

	    join_none
	end

        $display("FIN");

        
    end
endmodule
