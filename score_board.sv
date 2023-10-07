class score_board #(parameter drvrs = 4, parameter pckg_sz = 16);
	sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) trans_sb;
	sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) sb_aux[$];
	sb_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) chkr_sb_mbx;

	int num_trans;
	int num_trans_aux;

	int rprt_sb;

	task run();
		num_trans_aux = 0;
		$display("[%g] El Score Board inicio", $time);
		forever begin
			#1;
			if (chkr_sb_mbx.num()>0) begin
				chkr_sb_mbx.get(trans_sb);
				sb_aux.push_front(trans_sb);
				num_trans_aux++;
			end

			if((num_trans_aux > num_trans) && (chkr_sb_mbx.num() == 0)) begin
				$display("[SCOREBOARD] Imprimiendo Archivos");
				rprt_sb = $fopen("reporte_scoreboard.csv", "w");
				$fwrite(rprt_sb, ";Dato enviado; Tiempo Push; Tiempo Pop; Completado; Latencia; Dispositivo Receptor\n");
				for (int i = 0;i<sb_aux.size(); i++) begin
					$display("[DEBUG] %d", i);
					$fwrite(rprt_sb,"dispositivo emisor 0x%h; 0x%h; %g; %g; %b; %g; 0x%h\n",sb_aux[i].dsp_env, sb_aux[i].dato_enviado, sb_aux[i].tiempo_push, sb_aux[i].tiempo_pop, sb_aux[i].completado, sb_aux[i].latencia, sb_aux[i].dsp_rec);
				end
				$fclose(rprt_sb);
				break;
			end
		end
	
	endtask

endclass
