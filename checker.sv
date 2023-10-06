class checker_p  #(parameter drvrs =4, parameter pckg_sz = 16);
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) auxiliar;
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) emulado;
    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) to_sb;

    bus_pckg emul_fifo[$];
    bus_pckg_mbx drvr_chkr_mbx;
    bus_pckg_mbx mntr_chkr_mbx;
    sb_pckg_mbx chkr_sb_mbx;
    int contador_auxiliar;
    bit disponible=0;

    function new();
	this.emul_fifo = {};
	this.contador_auxiliar = 0;
	this.to_sb = new();
    endfunction

    task update();
	$display("[%g] El Checker se esta actualizando", $time);
	forever begin
	    drvr_chkr_mbx.get(transaccion);
	    emul_fifo.push_front(transaccion);
	end
    endtask

    task check();
	$display("[%g] El Checker esta revisando", $time);
	to_sb = new();
	emulado=new();
	transaccion=new();
	auxiliar=new();

	forever begin
            drv_chkr_mbx.get(transaccion); //Obtiene la transaccion de datos en el puntero que va de driver a checker
            transaccion.print("Checker: La transaccion ha sido recibida");
            to_sb.clean();

	    mntr_chkr_mbx.get(transaccion);
	    for (int i = 0; i < emul_fifo.size(); i++) begin

	        if (emul_fifo[i].dato == transaccion.dato && to_sb.destino==emul_fifo[i].destino)begin;
		//////////
		    disponible=1;  //Se encontro la transaccion
		    emulado =emul_fifo[i];
		    emul_fifo.delete(i); //borra el lugar en la cola para no volver a repetirlo  
		    
		    //to_sb.dato_enviado = emulado.dato;
		    //to_sb.Fuente = emulado.fuente;						  
	            //to_sb.retardo= emulado.retardo;
		    //to_sb.procedencia=transaccion.fuente;
                    //to_sb.Destino = transaccion.destino;

		    to_sb.tiempo_push = transaccion.tiempo;
		    to_sb.tiempo_pop = emul_fifo[i].tiempo;
		    to_sb.completado = 1;
		    to_sb.calc_latencia();
		    to_sb.print("[DEBUG]");
		    chkr_sb_mbx.put(to_sb);
	        end
		if (disponible==0) begin
		    transaccion.print("Dato que se transmite no calza con el esperado");
		end
	    end
	    
	end
    endtask


endclass


