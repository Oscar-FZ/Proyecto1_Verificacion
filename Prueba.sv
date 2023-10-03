`timescale 1ns / 1ps

class fifo #(parameter drvrs = 4, parameter pckg_sz = 16);
    bit push;
    bit pop;
    bit pndng_bus;
    bit pndng_monitor;
    bit [pckg_sz-1:0] data_out_monitor;
    bit [pckg_sz-1:0] data_out_bus;
    bit [pckg_sz-1:0] queue_in [$];
    bit [pckg_sz-1:0] queue_out [$];
    bit [7:0] id;
    
    
    function new (input int identification);
        this.push               = 0;
        this.pop                = 0;
        this.pndng_bus          = 0;
        this.pndng_monitor      = 0;
        this.data_out_monitor   = 0;
        this.data_out_bus       = 0;
        this.id                 = identification;
    endfunction
    
    function void receive_from_driver (input bit [pckg_sz-1:0] data_driver);
        if (this.push)
            queue_in.push_front(data_driver);
    endfunction
    
    function void send_to_monitor ();
        if (this.pop)
            data_out_monitor = queue_out.pop_back();
        
        if (queue_out.size() != 0)
            pndng_monitor = 1;
        else
            pndng_monitor = 0;
    endfunction
    
    
    function void receive_from_bus (input bit [pckg_sz-1:0] data_bus);
        if (this.push)
            queue_out.push_front(data_bus);
    endfunction
    
    function void send_to_bus ();
        if (this.pop)
            data_out_bus = queue_in.pop_back();
        
        if (queue_in.size() != 0)
            pndng_bus = 1;
        else
            pndng_bus = 0;
    endfunction
    
    function void print(input string tag);
        $display("[TIME %g]", $time);
        $display("%s", tag);
        $display("push=%b", this.push);
        $display("pop=%b", this.pop);
        $display("pndng_bus=%b", this.pndng_bus);
        $display("pndng_monitor=%b", this.pndng_monitor);
        $display("data_out_bus=%h", this.data_out_bus);
        $display("data_out_monitor=%h", this.data_out_monitor);
        $display("queue_in=%p", this.queue_in);
        $display("queue_out=%p", this.queue_out);
        $display("id=%d", this.id);
        
        
//        $display("[%g] %s push=%b, pop=%b, pending=%b, data_out=%h, queue=%p, id=%d, size=%d",
//            $time,
//            tag,
//            this.push,
//            this.pop,
//            this.pndng,
//            this.data_out,
//            this.queue,
//            this.id,
//            this.queue.size());
    endfunction
        
endclass


module Prueba_TB();
    parameter WIDTH = 16;
    parameter PERIOD = 10;
    parameter bits = 1;
    parameter drvrs = 4;
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
    
    fifo #(.drvrs(drvrs), .pckg_sz(pckg_sz)) pruebas [drvrs-1:0];
    
    initial begin
        for (int i = 0; i<drvrs; i++) begin
            pruebas[i] =new(i);
            #1;
        end
        
        for (int i = 0; i<drvrs; i++) begin
            pruebas[i].print("hola");
            #1;
        end
//        CLK_100MHZ = 1'b0;  
//        reset = 1'b1;
//        #(PERIOD);
//        reset = 1'b0;
//        while (pop == 1'b0) begin
//            pndng[0][0] = 1'b1;
//            D_pop[0][0] = 16'hFFFF;
//            #(PERIOD);        
//        end
//        pndng[0][0] = 1'b0;
//        D_pop[0][0] = 16'h0000;
        
    end



endmodule
