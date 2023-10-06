//La clase drvr_mntr es una clase que se puede usar para conducir y monitorear una interfaz de bus. 
//La clase tiene dos tareas principales:
	//Conducir el bus enviando paquetes de datos de una cola.
	//Monitorear el bus recibiendo paquetes de datos de una cola.
//La clase tiene una serie de parámetros que se pueden configurar por el usuario:
	//bits: El número de bits en el bus de datos.
	//drvrs: El número de controladores conectados al bus.
	//pckg_sz: El tamaño de los paquetes de datos.
Conducir el bus: La clase puede conducir el bus enviando paquetes de datos de una cola. La cola está poblada por el usuario.
Monitorear el bus: La clase puede monitorear el bus recibiendo paquetes de datos de una cola. La cola está poblada por la interfaz de bus.

class drvr_mntr #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);
	//Variables para FIFO
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
        this.id = identificador; //Se inicializa al identificador especificado como argumento de la funcion
    endfunction
  
    task update_drvr(); //Actualiza el estado del driver
	forever begin
	    @(negedge vif.clk);
	    pop = vif.pop[0][id];
	    vif.pndng[0][id] = pndng_bus;
        end
    endtask

    task update_mntr(); //Actualiza el estado del monitor
	forever begin
	    @(negedge vif.clk);
	    push = vif.push[0][id];
        end
    endtask
 
  
    task send_data_bus(); //Envios de mensajes al bus
	forever begin
	    @(posedge vif.clk);
	    vif.D_pop[0][id] = queue_in[$]; //Se carga el mensaje en la fifo de salida
	    if (pop) begin    
    	        queue_in.pop_back();
	    end

	    if (queue_in.size() != 0) 
                pndng_bus = 1;  //Se activa la bandera pending del bus cuando tenemos un dato esperando ser enviado
            else
                pndng_bus = 0;
	end
    endtask

    task receive_data_bus(); //Recepcion de mensajes del bus
	forever begin
	    @(posedge vif.clk);
	    if (push) begin  //Se carga el mensaje en la fifo de entrada
	        queue_out.push_front(vif.D_push[0][id]);
	    end
      
	    if (queue_out.size() != 0) begin 
                pndng_mntr = 1;  //Se tiene un dato esperando ser mostrado en el monitor
	    end
            else
                pndng_mntr = 0;
	end
    endtask     


    

    function void print(input string tag);   //Se imprimen el estado del controlador y del monitor
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

 
//La clase drvr_mntr_hijo es una subclase de la clase drvr_mntr. Esta subclase añade una serie de características adicionales, incluyendo:
	//La capacidad de comunicarse con otros controladores y monitores a través de buzones de correo.
	//La capacidad de retrasar el envío de paquetes de datos al bus
   
class drvr_mntr_hijo #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);
    drvr_mntr #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) dm_hijo;
    //virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) vif_hijo;

    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;    //Paquetes de datos que se envian al bus
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_mntr;


    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx;  //Se inicializan los Mailbox 
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;



    int espera;
    int id;
    
    function new (input int identification); // Inicializar los miembros de datos de una nueva instancia de la clase
      	dm_hijo = new(identification);
      	//dm_hijo.vif = vif_hijo;
        id = identification;
	transaccion = new();
	transaccion_mntr = new(.tpo(lectura));

	agnt_drvr_mbx = new();
	drvr_chkr_mbx = new();
	mntr_chkr_mbx = new();
    endfunction
    
    task run_drvr(); //Esta tarea se ejecuta en un bucle infinito y envía paquetes de datos al bus.
	// Inicializa el controlador y el monitor.
	$display("[ID] %d", id);
        $display("[%g] El Driver fue inicializado", $time);
	fork
            dm_hijo.update_drvr();
	    dm_hijo.send_data_bus();
	join_none
        @(posedge dm_hijo.vif.clk);
        forever begin // Obtiene un paquete de datos del buzón de correo `agnt_drvr_mbx`.
            dm_hijo.vif.reset = 0;
	    espera = 0;
            
	    agnt_drvr_mbx.get(transaccion);
	    while(espera <= transaccion.retardo) begin // Retrasa el envío del paquete de datos al bus
	        @(posedge dm_hijo.vif.clk);
		espera = espera + 1;
	    end
                
            if (transaccion.tipo == escritura) begin // Si el paquete de datos es de tipo `escritura`, envía el paquete de datos al bus.
                $display("[ESCRITURA]");
		transaccion.tiempo = $time;
                dm_hijo.queue_in.push_front(transaccion.dato);
		//transaccion.print("[DEBUG] Dato enviado");
		drvr_chkr_mbx.put(transaccion);
            end
        end
    endtask

    task run_mntr();
	// Inicializa el monitor
	$display("[ID] %d", id);
        $display("[%g] El Monitor fue inicializado", $time);
	
	fork
            dm_hijo.update_mntr();
	    dm_hijo.receive_data_bus();
	join_none
        
	forever begin	// Recibe un paquete de datos del bus.
            dm_hijo.vif.reset = 0;
            @(posedge dm_hijo.vif.clk);    
	    if (dm_hijo.pndng_mntr) begin
			// Coloca el paquete de datos recibido en el mailbox `mntr_chkr_mbx`.
	    	$display("[LECTURA]");
		transaccion_mntr.tiempo = $time;
		transaccion_mntr.dato = dm_hijo.queue_out.pop_back();
		mntr_chkr_mbx.put(transaccion_mntr);
		//transaccion.print("[DEBUG] Dato recivido");
	    end
        end
    endtask
endclass

//Es una clase que se utiliza para iniciar y detener los drivers y monitores de una arquitectura basada en bus.
class strt_drvr_mntr #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);
	drvr_mntr_hijo #(.bits(bits), .drvrs(drvrs), .pckg_sz(pckg_sz)) strt_dm [drvrs];
	
	function new();
		for(int i = 0; i < drvrs; i++) begin
			strt_dm[i] = new(i);
		end
	endfunction

	//Para cada driver, start_driver() crea un proceso fork que inicializa el driver
	task start_driver();
		for (int i = 0; i < drvrs; i++)begin
			fork
				automatic int j=i;
				begin
					strt_dm[j].run_drvr();
				end
			join_none
		end
	endtask

	//Para cada monitor, start_monitor() crea un proceso fork que inicializa el monitor
	task start_monitor();
		for (int i = 0; i < drvrs; i++)begin
			fork
				automatic int j=i;
				begin
					strt_dm[j].run_mntr();
				end
			join_none
		end
	endtask

endclass


