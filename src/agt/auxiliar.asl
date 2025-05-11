/* Initial beliefs and rules */

// Creencias que muestran la conexion entre dos salas y la puerta que los unen.
connect(kitchen, hall, doorKit1).
connect(kitchen, hallway, doorKit2).
connect(hall, kitchen, doorKit1).
connect(hallway, kitchen, doorKit2).
connect(bath1, hallway, doorBath1).
connect(bath2, bedroom1, doorBath2).
connect(hallway, bath1, doorBath1).
connect(bedroom1, bath2, doorBath2).
connect(bedroom1, hallway, doorBed1).
connect(hallway, bedroom1, doorBed1).
connect(bedroom2, hallway, doorBed2).
connect(hallway, bedroom2, doorBed2).
connect(bedroom3, hallway, doorBed3).
connect(hallway, bedroom3, doorBed3).
connect(hall, livingroom, doorSal1).        
connect(livingroom, hall, doorSal1).
connect(hallway, livingroom, doorSal2).       
connect(livingroom, hallway, doorSal2).   

battery(288). 	// numero de casillas. Lo máximo que podría tener que recorrer andaría en unas 40 tirando por lo alto.
batteryMax(288).// bateria maxima que tiene el auxiliar disponible. Es de la que dispone al inicio
contador(0). 	// numero de veces que el auxiliar ha salido de la bateria antes de tiempo
free. 			//muestra si el auxiliar está libre de acciones que realizar
                 

 

medicPend([]). 	// Donde vamos a manejar los medicamentos que tiene que tomar owner
medicActual([]).// Donde vamos a manejar los medicamentos que lleva el robot actualmente

medicRep([]). 	//Lista de medicinas que tenemos que reponer por caducidad
medicStock([]). // Lista de medicinas que tenemos que reponer por cantidad de medicamentos

/*************************************************************************/
/*************************  INICIALIZACIÓN  ******************************/
/*************************************************************************/

+!inicia : true <-  // Iniciamos planes básicos para la comprobación de batería y de stock
    .print("Iniciando recordatorios de medicamentos...");
    .time(H, M, S);

	!iniciarStock;
	!!alertaStock;
	!!batteryState.

+!iniciarStock <- 
	getStock;
	.findall([Med,Q],stock(Med,Q),L);
	+stockActual(L).

/*************************************************************************/
/*************************  BATERÍA  *************************************/
/*************************************************************************/


+!consumo(X) : battery(B) <- // Plan básico para la resta de batería del robot
	.print("-1 de batería: ", B);
	-battery(B);
	+battery(B-X).

+!batteryState: battery(B) & B <=0 <- // Si se queda sin bateria, manda mensaje
	.println("SIN BATERIA");
	.wait(3000);
	!batteryState.

+!batteryState : battery(B) & B < 75 & free <- // Si la batería del auxiliar es menor que 75, voy al puesto de carga
	-free;
	.print("Me queda poca batería. Voy al puesto de carga");
	!at(auxiliar, waitCharger);
	!comprobarCargadorLibre;
	
	while(.belief(at(enfermera,charger))){
		.wait(100);
		-at(enfermera,charger);
		!comprobarCargadorLibre;
	}
	!at(auxiliar, charger);
	useCharger;
	!cargarBateria;
	quitCharger;
	!at(auxiliar,afterChargerAuxiliar);
	+free;
	!batteryState.

+!batteryState: battery(B) & B < 75 & not free <-  // Si no esta libre deja vivo el plan
	.print("No estoy libre pero tengo que ir a cargar...");
	.wait(1000);
	!batteryState.

+!batteryState <- 	// En otro caso sigue vivo el plan
	!batteryState.

+!comprobarCargadorLibre <- // Comprueba si el cargador esta libre
	.send(enfermera,askOne, at(enfermera, charger)).

+!cargarBateria : battery(B) & batteryMax(BMax)<- // Si esta ya en el cargador, esperamos 3 segundo a que el robot se llene de batería
	.print("Cargando.....");
	.wait(3000);
	-battery(B);
	+battery(BMax);
	.print("He completado mi carga").


+!cancelarCargarBateria: contador(T) & batteryMax(B) <- 
	.println("Me han cancelado la carga, me quito un 5%");
	-contador(_);
	+contador(T+1);
	if(T==3){ //Caso que queremos decrementar
		-batteryMax(_);
		+batteryMax(B*0.95);
		-contador(_);
		+contador(0);
	}.

/*************************************************************************/
/*************************   STOCK  *************************************/
/*************************************************************************/

+!actualizarStock: battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO actualizarStock").

+!actualizarStock <- // Actualiza la creencia de stockActual con el stock real que está en el entorno
	-stockActual(L);
	!iniciarStock.

+!actualizarStock: battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO actualizarStock").

+!alertaStock: medicStock([]) <-  // Plan que se ejecuta contantemente, comprueba el stock y recorre el stock en busca de medicamentos con bajo stock
	.wait(1000);
	getStock;
	.findall([Med,Q],stock(Med,Q),Stock);
	!recorrerStock(Stock);
	!alertaStock.

+!alertaStock: true <- // En el caso de que se este yendo a por el stock
	!alertaStock.


+!recorrerStock: battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO recorrerStock").

+!recorrerStock([[Med,Q]|Cdr]): medicStock(L) <-  //Recorremos la lista en busca de medicamentos que la cantidad sea de menor de 20
    if(Q<=2 & not member(Med,L)){
        -medicStock(L);
		+medicStock([Med|L]);
    }
	!recorrerStock(Cdr).

+!recorrerStock([]) <- 			// Cuando termine de comprobar la lista
    !hayQueRecoger.

+!hayQueRecoger: battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO hayQueRecoger").

+!hayQueRecoger: battery(B) & B > 0 & medicStock(L) & free <- // Si hay algun medicamento que suministrar y esta libre vamos al delivery a recoger la medicina
	-free;
    .println("Yendo a reponer stock");
    !at(auxiliar, delivery);
    !cogerMedicinaStock;
    .wait(1000);
    !at(auxiliar, kit);
	if(not .belief(open(kit))){
		open(kit);
	}
	?medicActual(MActual);
	!addStock(MActual);
	!actualizarStock;
    if(not .belief(close(kit))){
		close(kit);
	}
	+free.

+!hayQueRecoger: medicStock([Car|Cdr]) & not free <- // Si el robot no esta libre, espera y deja vivo el plan
	.wait(1000);
	!hayQueRecoger.

+!hayQueRecoger: medicStock([]) <- true. // Si no hay ningun medicamento que reponer o suministrar

+!cogerMedicinaStock: battery(B) & B <=0 <-
	.println("SIN BATERIA, CANCELANDO cogerMedicinaStock");
	.wait(3000).
	
+!cogerMedicinaStock: battery(B) & B > 0 & medicStock([Med|Cdr]) & medicActual(L)<-  // Cogemos toda la medicina en medicStock y la ponemos en medicActual
	.println("Cogiendo ", Med);
	!consumo(2);							// Cuando coge la medicina del delivery gasta 2 de energia
	-medicStock(_);
	+medicStock(Cdr);
	-medicActual(_);
	+medicActual([Med|L]);
	!cogerMedicinaStock.

+!cogerMedicinaStock: medicStock([]) <-  // Cuando hemos cogido toda la medicina
	.println("Todos los medicamentos recogidos").

+!addStock: battery(B) & B <=0 <-
	.println("SIN BATERIA, CANCELANDO cogerMedicinaStock");
	.wait(3000).

+!addStock([Med|MedL]) : battery(B) & B > 0 <-  // Dejamos la medicina en el kit
	!consumo(2);
	.println("Reponiendo" , Med);
	reponerStock(Med);
	!addStock(MedL).

+!addStock([]) <- // Cuando hemos dejado toda la medicina en el kit
	.println("Todo el stock repuesto");
	-medicActual(_);
	+medicActual([]).

/*************************************************************************/
/*************************  CADUCIDAD  ***********************************/
/*************************************************************************/

+!reponerMedicinas: battery(B) & B <=0 <-
	.println("SIN BATERIA, CANCELANDO cogerMedicinaStock");
	.wait(3000).

+!reponerMedicinas : battery(B) & B > 0 & medicRep(Med) & free <- // Plan basico para el recogimiento de medicinas por caducidad
	-free;
    .println("Las medicinas ", Med, " van a caducar");
    .println("Yendo a la zona de entrega");
    !at(auxiliar, delivery);
	?medicRep(L);
	!cogerMedicina(L);
	-medicRep(_);
	+medicRep([]);
    .println("Medicinas",L,"recogidas");
    .wait(1000);
    .println("Yendo al kit a reponer");
    !at(auxiliar, kit);
	if(not .belief(open(kit))){
		open(kit);
	}
	!actualizarMedicina(L);
	if(not .belief(close(kit))){
		close(kit);
	}
	+free.
	
+!reponerMedicinas: not free <- // Si el auxiliar no está libre, mantiene vivo el plan
	!reponerMedicinas. 

+!reponerMedicinas: battery(B) & B <=0 <-
	.println("SIN BATERIA, CANCELANDO reponerMedicina");
	.wait(3000).

+!reponerMedicina(Medicina): medicRep([])  <- // Si el robot esta libre, y no tiene que recoger otra medicina, añade a la lista medicRep y llama a reponerMedicinas
	.println("Estoy libre, va a caducar la primera medicina: ",Medicina);
	-medicRep(_);
	+medicRep([Medicina]);
	!reponerMedicinas.

+!reponerMedicina(Medicina): not medicRep([]) <- // Si no es el primer medicamento que va a caducar, simplemente añade a la lista el medicamento
	.println("Estoy libre, va a caducar la medicina: ",Medicina);
	?medicRep(L);
	-medicRep(_);
	+medicRep([Medicina|L]).
  


+!cogerMedicina: battery(B) & B <=0 <-
	.println("SIN BATERIA, CANCELANDO cogerMedicina");
	.wait(3000).

+!cogerMedicina([Med|MedL]): medicActual(L) <- // Coge la medicina del delivery
	.println("Cogiendo ", Med);
	!consumo(2);							// Cuando coge la medicina del delivery gasta 2 de energia
	-medicActual(_);
	+medicActual([Med|L]);
	!cogerMedicina(MedL).

+!cogerMedicina([]) <-
	.println("Todos los medicamentos recogidos").


+!actualizarMedicina: battery(B) & B <=0 <-
	.println("SIN BATERIA, CANCELANDO actualizarMedicina");
	.wait(3000).

+!actualizarMedicina([Med|MedL]) : battery(B) & B > 0 <-  // Repone todas las medicinas y actualiza caducidades de los demas agentes
	!consumo(2); 
	.println("Reponiendo medicina, ",Med);
	.findall(caducidad(Med,Y), caducidad(Med,Y), U);
	.send(owner, untell, caducidad(Med,Y));
	.send(owner, achieve, cancelarPedido(Med));
    .send(enfermera, untell, caducidad(Med,Y));
    .send(owner, tell, U);
    .send(enfermera, tell, U);
	reponerMedCaducidad(Med);							
	!actualizarStock;
	!actualizarMedicina(MedL).

+!actualizarMedicina([]) <- 
	.println("Toda la medicina repuesta");
	-medicActual(_);
	+medicActual([]);
	+free.

/*************************************************************************/
/*************************  CÓDIGO BÁSICO  *******************************/
/*************************************************************************/

+!at(Ag, P) : at(Ag, P) <- 
	.println(Ag, " está en ",P);
	.wait(500).
+!at(Ag, P) : not at(Ag, P) <-   
	!go(P);                                        
	!at(Ag, P).            
	                                                   
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomAg) & battery(B) & B > 0 <- 
	!consumo(1);
	move_towards(P).  
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & not atDoor(Door) & battery(B) & B > 0 <- 
	!consumo(1);
	move_towards(Door); 
	!go(P).                     
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & not atDoor(Door) & battery(B) & B > 0 <- 
	!consumo(1); 
	move_towards(P); 
	!go(P).       
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  not connect(RoomAg, RoomP, _) & connect(RoomAg, Room, DoorR) &
		  connect(Room, RoomP, DoorP) & atDoor(DoorR) & battery(B) & B > 0 <- 
	!consumo(1);
	move_towards(DoorP); 
	!go(P). 
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  not connect(RoomAg, RoomP, _) & connect(RoomAg, Room, DoorR) &
		  connect(Room, RoomP, DoorP) & not atDoor(DoorR) & battery(B) & B > 0 <- 
	!consumo(1);
	move_towards(DoorR); 
	!go(P). 
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP & battery(B) & B > 0 <- 
	!consumo(1); //& not atDoor <-
	move_towards(P).

-!go(P): battery(B) & B <= 0 <- 
	.wait(3000);
	.println("¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿BIG ERROR?????????????????");
	.println("..........I DONT HAVE BATTERY LEFT......").                                                             
-!go(P) <- 
	.println("¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿ WHAT A FUCK !!!!!!!!!!!!!!!!!!!!");
	.println("..........SOMETHING GOES WRONG......").                                        

