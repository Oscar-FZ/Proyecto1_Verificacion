class score_board #(parameter drvrs = 4, parameter pckg_sz = 16);
    bus_pckg_mbx mntr_sb_mbx;
    bus pckg_mbx drvr_sb_mbx;

    solicitud_sb_mbx test_sb_mbx;

    sb_pckg_mbx chkr_sb_mbx;
    sb_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion_entrante;
    sb_pckg scoreboard [$];
    sb_pckg auxiliar_array[$];

    sb_pckg pckg_auxiliar;

    shortreal retardo_promedio[drvrs-1:0];
    solicitud_sb orden;
    int size_sb = 0;
    int transacciones_completadas = 0;
    int retardo_total = 0;
    
    int latencia_max;
    int latencia_min;
    integer i,j;
    int max;
    int ancho;
	
    task run();
	$display("[%g] El Score Board ha iniciado", $time);

	forever begin
	    if (mntr_sb_mbx.num()>0) begin
		mntr_sb_mbx.get(transaccion_entrante);
		transaccion_entrante.print("[SCORE BOARD] Transaccion recibida desde el Monitor");
		if (trans_entrante.completado)begin
		    retardo_total[trans_entrante.Destino] = retardo_total[trans_entrante.Destino] + trans_entrante.latencia;
		    trans_completas[trans_entrante.Destino]+=1;
		end
                scoreboard.push_back(trans_entrante);

	    end else begin
		if(test_sb_mbx.num()>0)begin
		    test_sb_mbx.get(orden);
		
		    case (orden)
			retraso_promedio:begin //Retraso promedio en la entrega de paquetes x terminal
			    $display("\nScore board: Ejecutando orden de calculo de retardo promedio");
			    for(int i=0;i<drvrs;i++)begin				
			        retardo_promedio[i]=retardo_total[i] / trans_completas[i];
			        $display("[%g] Score board: El retardo promedio en dispositivo[%g] es: %g nS",$time,i,retardo_promedio[i]);	
			    end
		        end


			anchomax:begin
			    $display("\nScore board: Ejecutando orden de ancho de banda maximo");
			    size_sb=this.scoreboard.size();
			    latencia_max=0;
			    for(int m=0;m<size_sb;m++)begin
				if (scoreboard[m].latencia>latencia_max)begin	
				    latencia_max=scoreboard[m].latencia;
				end
			    end
			    ancho=pckg_sz/(latencia_min*(0.00000001));
			    $display(" \n El ancho de banda maximo del bus es: %g bits/segundo \n",ancho);
			end
			
			anchomin:begin
			    $display("Score board: Ejecutando orden de ancho de banda minimo");
			    size_sb=this.scoreboard.size();
			    latencia_min=99999999999;
			    for(int m=0;m<size_sb;m++)begin
			        if (scoreboard[m].latencia<latencia_min)begin 
				    latencia_min=scoreboard[m].latencia;
				end							
			    end
			    ancho=pckg_sz/(latencia_min*(0.00000001));//Escalado al ser en nanosegundos
			    $display(" \n El ancho de banda minimo del bus es: %d bits/segundo \n",ancho);

			end						


			reporte_completo:begin //Reporte de los paquetes enviados recibidos en formato csv. Se debe incluir tiempo de envío terminal de procedencia, terminal de destino tiempo de recibido, retraso en el envío.
			    $display("\nScore board: Ejecutaando orden de reporte completo");
		            size_sb=this.scoreboard.size();
	               	    j = $fopen("output.csv", "w");
			    $fwrite(f, "T_envio  , Fuente,  Procedencia, Destino ,T_recibido, retraso, dato \n");
			    for (int i=0;i<size_sb;i++)begin
				pckg_auxiliar=scoreboard.pop_front; 
				$fwrite(f, "%d, %d, %d, %d, %d, %d, %d \n", 
				pckg_auxiliar.tiempo_envio, 
				pckg_auxiliar.Fuente,
				pckg_auxiliar.procedencia, 
				pckg_auxiliar.Destino,
				pckg_auxiliar.tiempo_recibido,
				pckg_auxiliar.retardo,
				pckg_auxiliar.dato_enviado);

				auxiliar_array.push_back(pckg_auxiliar);
			    end
			    scoreboard=auxiliar_array;
			end


		    endcase
		end 
	    end			
        end
    endtask
endclass
