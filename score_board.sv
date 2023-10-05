class score_board #(parameter drvrs = 4, parameter pckg_sz = 16);
    bus_pckg_mbx mntr_sb_mbx;
    bus pckg_mbx drvr_sb_mbx;
    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_entrante;
    sb_pckg scoreboard [$];
    sb_pckg auxiliar_array[$];

    shortreal retardo_promedio;
    solicitud_sb orden;
    int size_sb = 0;
    int transacciones_completadas = 0;
    int retardo_total = 0;

    task run();
	$display("[%g] El Score Board ha iniciado", $time);

	forever begin
	    if (mntr_sb_mbx.num()>0) begin
		mntr_sb_mbx.get(transaccion_entrante);
		transaccion_entrante.print("[SCORE BOARD] Transaccion recibida desde el Monitor");

	    end
	end
    endtask



endclass
