//La clase agent representa un agente del bus. 
//Su función es generar transacciones aleatorias y enviarlas a los drivers del bus.
class agent #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16);
	
	//Se definen los atributos que van a tener las variables de la clase
	bus_pckg_mbx #(.drvrs(drvrs), .pckg_sz(pckg_sz)) agnt_drvr_mbx[drvrs];
	instr_pckg_mbx test_agnt_mbx;

	instruccion tipo;
	bus_pckg #(.drvrs(drvrs), .pckg_sz(pckg_sz)) transaccion;

	int num_trans;
	int max_retardo_agnt;
	int retardo_agnt;

	function new(); //Inicializa los atributos de la clase
		for (int i = 0; i < drvrs; i++) begin
			agnt_drvr_mbx[i] = new();
		end
		test_agnt_mbx = new();
	endfunction;


	task run();
		$display("[%g] El Agente fue iniciado", $time);
		forever begin
			#1;
			if (test_agnt_mbx.num()>0) begin  //Si hay instrucciones, el código las obtiene y las ejecuta
				test_agnt_mbx.get(tipo);
				case(tipo)
					aleatorio: begin
					//El código genera el número de transacciones que se especifica en el atributo num_trans.
						for (int i = 0; i<num_trans; i++) begin
							$display("%d", i);
							transaccion = new();
							transaccion.max_retardo = max_retardo_agnt;
							transaccion.randomize();
							transaccion.dato = {transaccion.direccion, transaccion.info};
							transaccion.print("[AGENT]");
							agnt_drvr_mbx[transaccion.dispositivo].put(transaccion);

						end
					end
				endcase	
			end
		end
	endtask


endclass
