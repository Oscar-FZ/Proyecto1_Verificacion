class score_board #(parameter drvrs = 4, parameter pckg_sz = 16);
	//Mailbox
    bus_pckg_mbx mntr_sb_mbx; //Recibir paquetes del monitor
    bus pckg_mbx drvr_sb_mbx; //Enviar a los dispositivos conectados al bus
    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_entrante; //Almacenar un paquete
    sb_pckg scoreboard [$]; //Almacenar un historial de paquetes
    sb_pckg auxiliar_array[$];

    shortreal retardo_promedio; //Almacenar el retardo promedo de todas las trasacciones
    solicitud_sb orden; //Almacena una orden recibida de la unidad de control
    int size_sb = 0;
    int transacciones_completadas = 0;
    int retardo_total = 0;

    task run();
	$display("[%g] El Score Board ha iniciado", $time);

	forever begin
	    if (mntr_sb_mbx.num()>0) begin //Verifica si hay paquetes disponibles en el mailbox  mntr_sb_mbx
		mntr_sb_mbx.get(transaccion_entrante); // obtiene un paquete de el mailbox y lo almacena en la variable transaccion_entrante
		transaccion_entrante.print("[SCORE BOARD] Transaccion recibida desde el Monitor");

		// Cambio sugerido: Agregar más información al reporte de la consola
		$display("Origen: %d, Destino: %d, Tipo: %d, Latencia: %d",
			transaccion_entrante.Origen,
			transaccion_entrante.Destino,
			transaccion_entrante.Tipo,
			transaccion_entrante.latencia);

	    end
	end
    endtask


endclass

