`timescale 1ns / 1ps
`include "transacttions.sv"



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
            fifo #(.drvrs(drvrs), .pckg_sz(pckg_sz)) trans_fifo = new(1);
            vif.reset = 0;
            vif.pndng[0] = {0,0,0,0};
            vif.D_pop[0] = {0,0,0,0};
	    espera = 0;
            while (espera < 30) begin
  	    	@(posedge vif.clk);
		espera = espera +1; 
	    end
            $display("ANTES DEL CASE");
            case(tipo_trans)
                lectura: begin
                    $display("[LECTURA]");
                end
                
                escritura: begin
		    vif.reset = 1;
		    @(posedge vif.clk);
		    vif.reset = 0;
                    trans_fifo.queue_in.push_front(datos);
                    trans_fifo.bus_pndng_upt();
		    vif.pndng[0][id] = trans_fifo.pndng_bus;
		    trans_fifo.send_data_bus();
		    vif.D_pop[0][id] = trans_fifo.data_out_bus;
		    trans_fifo.print("[DEBUG]");

		    while (vif.pop[0][id] == 0) begin
			@(posedge vif.clk);
			$display("[DEBUG] esperando pop ...");
			//trans_fifo.send_data_bus();
			//vif.D_pop[0][id] = trans_fifo.data_out_bus;
		    end
		    @(posedge vif.clk);
		    trans_fifo.bus_pndng_upt();
		    vif.pndng[0][id] = trans_fifo.pndng_bus;
		    //vif.D_pop[0][id] = 0;

	            //while (vif.pndng[0][id] == 1) begin
		    //	@(posedge vif.clk);
		    //	trans_fifo.bus_pndng_upt();
	            //	vif.pndng[0][id] = trans_fifo.pndng_bus;
		    //	if (vif.pop[0][id] == 1) begin
		    //	    trans_fifo.send_data_bus();
		    //	    trans_fifo.bus_pndng_upt();
		    // 	    vif.D_pop[0][id] = trans_fifo.data_out_bus;
		    //	    trans_fifo.print("[DEBUG]");
		    //	    $display("[%g] [DEBUG] POP!", $time);
		    //	    break;
		    //	end
		        //trans_fifo.bus_pndng_upt();
			//vif.pndng[0][id] = trans_fifo.pndng_bus;
			//$display("[%g] [DEBUG] Esperando pop...", $time);
			//@(posedge vif.clk);
		    //end
		    //@(posedge vif.clk);
		    //@(posedge vif.clk);
		    //@(posedge vif.clk);
		    //vif.pndng[0][id] = trans_fifo.pndng_bus;
		    //vif.D_pop[0][id] = 0;

	            while (vif.push[0][id] == 0) begin
	  	        @(posedge vif.clk);
		    	$display("[%g] [DEBUG] Esperando push ...", $time);
		    end
		    $display("[DEBUG] PUSH!");
   
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
	    @(posedge vif.clk);
        end
    endtask
endclass
