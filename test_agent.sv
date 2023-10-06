`timescale 1ns / 10ps
`default_nettype none
`include "transacttions.sv"
`include "agent.sv"

module agente_DUT();
	parameter bits = 1;
	parameter drvrs = 4;
	parameter pckg_sz = 16;


	agent #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) mi_agent;

	bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx [drvrs];
	instr_pckg_mbx test_agnt_mbx;

	instruccion tipo;

	initial begin
		
		for (int j = 0; j < drvrs; j++) begin
			agnt_drvr_mbx[j] = new();
		end
		
		test_agnt_mbx = new();

		mi_agent = new();

		for (int i = 0; i < drvrs; i++) begin
			mi_agent.agnt_drvr_mbx[i] = agnt_drvr_mbx[i];
		end

		mi_agent.test_agnt_mbx = test_agnt_mbx;
		mi_agent.num_trans = 10;
		mi_agent.max_retardo_agnt = 20;

		tipo = aleatorio;
		test_agnt_mbx.put(tipo);

		mi_agent.run();


	end

endmodule
