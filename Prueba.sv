`timescale 1ns / 1ps

module Prueba_TB();
    parameter WIDTH = 16;
    parameter PERIOD = 10;
    parameter bits = 1;
    parameter drvrs = 8;
    parameter pckg_sz = 16;
    parameter broadcast = {8{1'b1}} ;

    bit CLK_100MHZ;                                     //in
    bit reset;                                          //in
    bit pndng   [bits-1:0][drvrs-1:0];                  //in
    bit push    [bits-1:0][drvrs-1:0];                  //out
    bit pop     [bits-1:0][drvrs-1:0];                  //out
    bit [pckg_sz-1:0]   D_pop   [bits-1:0][drvrs-1:0];  //in
    bit [pckg_sz-1:0]   D_push  [bits-1:0][drvrs-1:0];  //out
    
    always #(PERIOD/2) CLK_100MHZ=~CLK_100MHZ;
    
    bs_gnrtr_n_rbtr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz), .broadcast(broadcast)) bus_DUT
    (
        .clk    (CLK_100MHZ),
        .reset  (reset),
        .pndng  (pndng),
        .push   (push),
        .pop    (pop),
        .D_pop  (D_pop),
        .D_push (D_push)
    );
    
    initial begin
        CLK_100MHZ = 1'b0;  
        reset = 1'b1;
        #(PERIOD);
        reset = 1'b0;
        while (pop == 1'b0) begin
            pndng[0][0] = 1'b1;
            D_pop[0][0] = 16'hFFFF;
            #(PERIOD);        
        end
        pndng[0][0] = 1'b0;
        D_pop[0][0] = 16'h0000;
        
    end



endmodule
