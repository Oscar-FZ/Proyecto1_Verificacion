//Esta clase representa el checker de paquetes de una red de buses. 
//Su función es verificar que los paquetes recibidos sean los mismos que los enviados
//y calcular la latencia de cada paquete.
class checker_p  #(parameter drvrs =4, parameter pckg_sz = 16);

	//Se definen los atributos que van a tener las variables de la clase
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;
 
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) auxiliar;
    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) to_sb;

    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) emul_fifo[$];
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) drvr_chkr_mbx;
    bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) mntr_chkr_mbx;
    sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;
    int contador_auxiliar;

    function new(); //Inicializa los atributos de la clase
	emul_fifo = {};
	contador_auxiliar = 0;
	to_sb = new();
	transaccion = new();

	drvr_chkr_mbx = new();
	mntr_chkr_mbx = new();
	chkr_sb_mbx = new();
    endfunction

    task update(); //Actualiza el estado de la clase checker_p
	$display("[%g] El Checker se esta actualizando", $time);
	forever begin
	    $display("WOAH");
	    drvr_chkr_mbx.get(transaccion); //Obtiene un paquete de bus del controlador a través del mailbox
	    $display("Transaccion recibida");
	    emul_fifo.push_front(transaccion); //Utiliza la cola emul_fifo para almacenar los paquetes de bus recibidos
	end
    endtask

    task check(); // verifica los paquetes de bus recibidos y calcula la latencia de cada paquete
	$display("[%g] El Checker esta revisando", $time);
	forever begin
	    mntr_chkr_mbx.get(transaccion); //Obtiene un paquete de bus del monitor
	    for (int i = 0; i < emul_fifo.size(); i++) begin //Recorre la cola en busca de un paquete que coincida con el paquete recibido del monitor
	        if (emul_fifo[i].dato == transaccion.dato) begin //Si se encuentra un paquete coincidente, el código copia los datos del paquete a la variable to_sb
		    to_sb.dato_enviado = emul_fifo[i].dato;
		    to_sb.tiempo_push = transaccion.tiempo;
		    to_sb.tiempo_pop = emul_fifo[i].tiempo;
		    to_sb.completado = 1;
		    to_sb.calc_latencia();
		    to_sb.print("[CHECKER]");
		    chkr_sb_mbx.put(to_sb);
	        end
	    end
	end
    endtask
endclass


