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
    
    function void bus_pndng_upt ();
        if (this.queue_in.size() != 0) 
            this.pndng_bus = 1;
        else
            this.pndng_bus = 0;
    endfunction
    
    function void monitor_pndng_upt ();
        if (this.queue_out.size() != 0) 
            this.pndng_monitor = 1;
        else
            this.pndng_monitor = 0;
    endfunction
    
    function void send_data_bus();
        if (this.push == 1);
            this.data_out_monitor = this.queue_in.pop_back();
        
    endfunction
    
    function void receive_data_bus(input bit [pckg_sz-1:0] data_bus);
        if (this.pop == 1);
            this.queue_out.push_front(data_bus);
        
    endfunction
    
    function void print(input string tag);
        $display("---------------------------");
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
        $display("---------------------------");
        
    endfunction
endclass


interface bus_if #(parameter bits = 1,parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}}) 
    (
        input clk
    );
    
    logic reset;
    logic pndng[bits-1:0][drvrs-1:0];
    logic push[bits-1:0][drvrs-1:0];
    logic pop[bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0];
endinterface 
