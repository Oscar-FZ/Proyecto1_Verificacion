class checker_p  #(parameter drvrs =4, parameter pckg_sz = 16);
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;
    bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) auxiliar;
    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) to_sb;

    bus_pckg emul_fifo[$];
    bus_pckg_mbx drvr_chkr_mbx;
    bus_pckg_mbx mntr_chkr_mbx;
    sb_pckg_mbx chkr_sb_mbx;
    int contador_auxiliar;

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
	forever begin
	    mntr_chkr_mbx.get(transaccion);
	    for (int i = 0; i < emul_fifo.size(); i++) begin
	        if (emul_fifo[i].dato == transaccion.dato) begin
		    to_sb.dato_enviado = emul_fifo[i].dato;
		    to_sb.tiempo_push = transaccion.tiempo;
		    to_sb.tiempo_pop = emul_fifo[i].tiempo;
		    to_sb.completado = 1;
		    to_sb.calc_latencia();
		    to_sb.print("[DEBUG]");
		    chkr_sb_mbx.put(to_sb);
	        end
	    end
	end
    endtask


endclass


