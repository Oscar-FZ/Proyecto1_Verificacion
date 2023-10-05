class drvr_mntr #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);

    bit pop;
    bit push;
    bit pndng_bus;
    bit pndng_mntr;
    bit [pckg_sz-1:0] data_bus_in;
    bit [pckg_sz-1:0] data_bus_out;
    bit [pckg_sz-1:0] queue_in [$];
    bit [pckg_sz-1:0] queue_out [$];
    int id;
  
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) vif;
  
    function new (input int identificador);
        this.pop = 0;
        this.push = 0;
      	this.pndng_bus = 0;
        this.pndng_mntr = 0;
   	this.data_bus_in = 0;
      	this.data_bus_out = 0;
        this.queue_in = {};
      	this.queue_out = {};
        this.id = identificador;
    endfunction
  
    task pndng_upt ();
	forever begin
	    @(negedge vif.clk);
            if (queue_in.size() != 0) 
                pndng_bus = 1;
            else
                pndng_bus = 0;
      
      	    if (queue_out.size() != 0) 
                pndng_mntr = 1;
            else
                pndng_mntr = 0;
	    
	    pop = vif.pop[0][id];
	    push = vif.push[0][id];
	    vif.pndng[0][id] = pndng_bus;
        end
    endtask
  
    task send_data_bus();
	forever begin
	    @(posedge vif.clk);
	    if (pop) begin
    	        data_bus_in = queue_in.pop_back();
    	    	vif.D_pop[0][id] = data_bus_in;
	    end		
	end
    endtask

    

    function void print(input string tag);
        $display("---------------------------");
        $display("[TIME %g]", $time);
        $display("%s", tag);
        $display("push=%b", this.push);
        $display("pop=%b", this.pop);
        $display("pndng_bus=%b", this.pndng_bus);
        $display("pndng_monitor=%b", this.pndng_mntr);
        $display("data_bus_in=%h", this.data_bus_in);
        $display("data_bus_out=%h", this.data_bus_out);
        $display("queue_in=%p", this.queue_in);
        $display("queue_out=%p", this.queue_out);
        $display("id=%d", this.id);
        $display("---------------------------");

    endfunction
endclass

    
class drvr_mntr_hijo #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);
    drvr_mntr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) dm_hijo;

    bus_pckg_mbx agnt_drvr_mbx;
    //bus_pckg_mbx drvr_chkr_mbx;
    //bus_pckg_mbx mntr_chkr_mbx;

    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;


    int espera;
    int id;
    drvr_mntr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) dm_hijo = new(0);
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) vif_hijo;
    
    function new (input int identification);
      	dm_hijo = new(identification);
      	dm_hijo.vif = vif_hijo;
        id = identification;
	agnt_drvr_mbx = new();
	//drvr_chkr_mbx = new();
	//mntr_chkr_mbx = new();
	transaccion = new();
    endfunction
    
    task run();
        $display("[%g] El Driver/Monitor fue inicializado", $time);
	fork
            dm_hijo.pndng_upt();
	    dm_hijo.send_data_bus();
	join_none
        //@(posedge vif_hijo.clk);
        //vif_hijo.reset = 1;
        @(posedge vif_hijo.clk);
        forever begin
            vif_hijo.reset = 0;
            vif_hijo.pndng[0][id] = 0;
            vif_hijo.D_pop[0][id] = 0;
            
	    agnt_drvr_mbx.get(transaccion);

            case(transaccion.tipo)
                lectura: begin
                    $display("[LECTURA]");
                end
                
                escritura: begin
                    $display("[ESCRITURA]");
                    dm_hijo.queue_in.push_front(transaccion.dato);
                  
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

