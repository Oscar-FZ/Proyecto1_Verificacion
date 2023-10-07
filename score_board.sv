class score_board #(parameter drvrs = 4, parameter pckg_sz = 16);
	sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) trans_sb;
	sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) sb_aux[$];
	sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;

	int num_trans;
	int num_trans_aux;
	int inicio;
	int j;
	int rprt_sb;

	function new();
	    chkr_sb_mbx = new();
	    inicio = 1;
	    num_trans_aux = 0;

	endfunction

	task run();
		num_trans_aux = 0;
		$display("[SCOREBOARD][%g] El Score Board inicio", $time);
		forever begin
			#1;
			if (chkr_sb_mbx.num()>0) begin
				$display("[SCOREBOARD] Transaccion recibida");
				chkr_sb_mbx.get(trans_sb);
				//sb_aux.push_front(trans_sb);
				num_trans_aux++;

				$display("[SCOREBOARD] Imprimiendo Archivos");
				if (inicio) begin
					rprt_sb = $fopen("reporte_scoreboard.csv", "w");
					$fwrite(rprt_sb, ";Dato enviado; Tiempo Push; Tiempo Pop; Completado; Latencia; Dispositivo Receptor\n");
					$fclose(rprt_sb);
					inicio = 0;
				end
				rprt_sb = $fopen("reporte_scoreboard.csv", "a");

				$display("[SCOREBOARD] ESCRIBIENDO %d", num_trans_aux);
				$fwrite(rprt_sb,"[%d] dispositivo emisor 0x%h; 0x%h; %g; %g; %b; %g; 0x%h\n",num_trans_aux ,trans_sb.dsp_env, trans_sb.dato_enviado, trans_sb.tiempo_push, trans_sb.tiempo_pop, trans_sb.completado, trans_sb.latencia, trans_sb.dsp_rec);
				$fclose(rprt_sb);
			end

			if (num_trans_aux == num_trans) break;
		end
	
	endtask

endclass
