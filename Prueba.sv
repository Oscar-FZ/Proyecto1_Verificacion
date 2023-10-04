`timescale 1ns / 1ps
`include "Library.sv"
`include "driver_monitor.sv"

module DUT_TB();
    parameter WIDTH = 16;
    parameter PERIOD = 10;
    parameter bits = 1;
    parameter drvrs = 4;
    parameter pckg_sz = 16;
    parameter broadcast = {8{1'b1}} ;

    bit CLK_100MHZ;                                     //in
    //bit reset;                                          //in
    //bit pndng   [bits-1:0][drvrs-1:0];                  //in
    //bit push    [bits-1:0][drvrs-1:0];                  //out
    //bit pop     [bits-1:0][drvrs-1:0];                  //out
    //bit [pckg_sz-1:0]   D_pop   [bits-1:0][drvrs-1:0];  //in
    //bit [pckg_sz-1:0]   D_push  [bits-1:0][drvrs-1:0];  //out
    
    driver #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) driver_UT [drvrs-1:0];
  
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
      	
        $display("INICIO");
        for (int i = 0; i<drvrs; i++) begin
            $display("[%d]", i);
            driver_UT[i] =new(i);
            #1;
        end    
        
      	driver_UT[0].vif = _if;
	#10;
        driver_UT[0].run(escritura, 16'hABBA);
        #150;	
        $display("FIN");

        
    end
endmodule
