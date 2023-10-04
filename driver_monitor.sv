`timescale 1ns / 1ps
`include "transactions.sv"



typedef enum {
    lectura,
    escritura,
    reset,
    broadcast} transaccion;
    
class driver #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);
    int espera;
    int id;
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) vif;
    
  	function new (input int identification);
        this.id = identification;
    endfunction
    
    
  	task run(input transaccion tipo_trans, input bit [pckg_sz-1:0] datos);
        $display("[%g] El Driver/Monitor fue inicializado", $time);
        @(posedge vif.clk);
        vif.reset = 1;
        @(posedge vif.clk);
        forever begin
          	fifo #(.drvrs(drvrs), .pckg_sz(pckg_sz)) trans_fifo [drvrs-1:0];
            vif.reset = 0;
          	vif.pndng[0][this.id] = 0;
          	vif.D_pop[0][this.id] = 0;
            
            case(tipo_trans)
                lectura: begin
                    $display("[LECTURA]");
                end
                
                escritura: begin
                    trans_fifo.queue_in.push_front(datos);
                    trans_fifo.bus_pndng_upt();
                  while (!vif.push[0][this.id]);
                        $display("[ESCRITURA] Esperando push...");
                  vif.D_pop[0][this.id] = trans_fifo.queue_in.pop_back();   
                end
                
                reset: begin
                    $display("[RECET]");
                end
                
                broadcast: begin
                    $display("[BROADCAST]");
                end
                
                default: begin
                    $display("[DEFAULT]");
                    $finish;
                end
            endcase
        end
    endtask
endclass
