/* Initial beliefs and rules */

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

battery(45). //numero de casillas. Lo máximo que podría tener que recorrer andaría en unas 40 tirando por lo alto.

// initially, robot is free
free.
                 

 

medicPend([]). // Donde vamos a manejar los medicamentos que tiene que tomar owner
medicActual([]). // Donde vamos a manejar los medicamentos que lleva el robot actualmente

medicRep([]). //Lista de medicinas para reponer
medicStock([]).

/* Plans */


+!inicia : true <- 
    .print("Iniciando recordatorios de medicamentos...");
    .time(H, M, S);
    .findall(consumo(X,T,H,M,S), pauta(X,T), L);
    !iniciarContadores(L);
	!!batteryState;
	!!alertaStock;
	!iniciarStock.

+!iniciarContadores([consumo(Medicina,T,H,M,S)|Cdr]) <-
    if(S+T>=60){ 
		+consumo(Medicina,T,H,M+1,S+T-60);
		.print(consumo(Medicina,T,H,M+1,S+T-60));	
	}else{
		+consumo(Medicina,T,H,M,S+T);
		.print(consumo(Medicina,T,H,M,S+T));
	}
	
    !iniciarContadores(Cdr).

+!iniciarContadores([]) <- .print("Inicialización completada").

+!iniciarStock <- 
	getStock;
	.findall([Med,Q],stock(Med,Q),L);
	+stockActual(L).

+!actualizarStock <-
	-stockActual(L);
	!iniciarStock.


+!reponerMedicina(Medicina) : battery(B) & B > 0 & medicRep([])<- 
	!consumo(1);
	-medicRep(_);
	+medicRep([Medicina]);
    .println("La medicina ", Medicina, " va a caducar");
    .println("Yendo a la zona de entrega");
    !at(auxiliar, delivery);
    .println("Medicinas recogidas");
    .wait(1000);
    .println("Yendo a la nevera a reponer");
    !at(auxiliar, kit);
    open(kit);
	?medicRep(L);
	!actualizarMedicina(L);
    close(kit);
	!at(auxiliar, initial).

+!reponerMedicina(Medicina): battery(B) & B > 0 & medicRep(Med) <-
	.concat(Med,[Medicina],L);
	-medicRep(_);
	+medicRep(L).

+!actualizarMedicina([]) <-
	.println("TODA LA MEDICINA REPUESTA");
	-medicRep(_);
	+medicRep([]).

+!actualizarMedicina([Med|MedL]) : battery(B) & B > 0 <- 
	!consumo(1);
	.findall(caducidad(Med,Y), caducidad(Med,Y), U);
	.send(owner, untell, caducidad(Med,Y));
	.println("ELIMINANDOOOOOOOOOOOOOOO" , Med);
	.send(owner, achieve, cancelarPedido(Med));
    .send(enfermera, untell, caducidad(Med,Y));
    .send(owner, tell, U);
    .send(enfermera, tell, U);
	!actualizarMedicina(MedL).

+!comprobarHora(_,_,_,_) <-
	.println("No hora que comprobar").

+!comprobarStock: not medicActualOwner(L) <- 
	.print("Esperando a que owner me diga que medicacion ha tomado...");
	.wait(500);
	!comprobarStock.

+!comprobarStock: medicActualOwner(L) <-
	.println(L);
	getStock;
	.findall([Med,Q],stock(Med,Q),StockNuevo);
	!comprobarMedicinas(L,StockNuevo);
	-medicActualOwner(_);
	!actualizarStock.

+!alertaStock: true <-
	.wait(1000);
	getStock;
	.findall([Med,Q],stock(Med,Q),Stock);
	.println("EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
	!recorrerStock(Stock).


+!recorrerStock([[Med,Q]|Cdr]): medicStock(L) <- 
    if(Q<=2 & not member(Med,L)){
		.println("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
        -medicStock(L);
		+medicStock([Med|L]);
    }
	!recorrerStock(Cdr).

+! recorrerStock([]) <- 
	.println("Recorrido");
    .println("Yendo a reponer stock");
    !at(auxiliar, delivery);
    .println("Stock recogido");
    .wait(1000);
    !at(auxiliar, kit);
    open(kit);
	?medicStock(L);
	!actualizarStock(L);
    close(kit);
	!at(auxiliar, initial).

+!actualizarStock([]) <-
	.println("TODA EL STOCK REPUESTO");
	-medicStock(_);
	+medicStock([]).

+!actualizarStock([Med|MedL]) : battery(B) & B > 0 <- 
	!consumo(1);
	.findall(stock(Med,Y), stock(Med,Y), U);
	.send(owner, untell, stock(Med,Y));
	.println("ELIMINANDOOOOOOOOOOOOOOO" , Med);
    .send(owner, tell, U);
	!actualizarStock(MedL).

+!comprobarMedicinas([Med|Cdr],StockNuevo) <-
	!comprobarMedicina(Med,StockNuevo);
	!comprobarMedicinas(Cdr,StockNuevo).

+!comprobarMedicinas([],StockNuevo) : battery(B) & B > 0 <- 
	!consumo(1); 
	.print("Todas medicinas comprobadas").

+!comprobarMedicina(MedicinaTomada,[[MedicinaTomada,Q1]|Cdr1]) <-
	.belief(stockActual(L));
	!comprobarStockMedicina(MedicinaTomada,Q1,L).
	

+!comprobarMedicina(MedicinaTomada,[[_,_]|Cdr1]) <-
	!comprobarMedicina(MedicinaTomada,Cdr1).


+!comprobarStockMedicina(MedicinaTomada,Q1,[[MedicinaTomada,Q2]|Cdr]) <- 
	if (Q1 < Q2){
		.print("Owner se ha tomado medicina ",MedicinaTomada);
	}else{
		.print("AVISO! Owner no se ha tomado  ", MedicinaTomada);
	}
	.wait(1000).

+!comprobarStockMedicina(MedicinaTomada,Q1,[[_,_]|Cdr]) : battery(B) & B > 0 <- 
	!consumo(1);
	!comprobarStockMedicina(MedicinaTomada,Q1,Cdr).

+!enviarMedicinaPendiente: medicPend(L) <-
	.send(owner,achieve,medicinaRecibida(L)).

+!darMedicina([],H,M,S) <-
	.println("TODA LA MEDICINA TOMADA");
	-medicActual(_);
	+medicActual([]).

+!darMedicina([Med|MedL],H,M,S) : battery(B) & B > 0 <- 
	!consumo(1);
	.time(HH,MM,SS);
	.println("Dando al owner la medicina: ", Med, " a la hora: H:",HH,":",MM,":",SS);
	!darMedicina(MedL,H,M,S).


+!addMedicinaPendiente(Medicina): medicPend(Med) <-
	.concat(Med,[Medicina],L);
	-medicPend(_);
	+medicPend(L).

+!addMedicinaActual(Medicina): medicActual(Med) <-
	.concat(Med,[Medicina],L);
	-medicActual(_);
	+medicActual(L).




+!cogerTodaMedicina([Car|Cdr]) <-
		.println("Cojo la medicina ",Car);
		getMedicina(Car);
		!addMedicinaActual(Car);
		!cogerTodaMedicina(Cdr).

+!cogerTodaMedicina([]) : battery(B) & B > 0 <- 
		!consumo(1);
		.println("He cogido toda la medicina");
		!actualizarStock.

+!medicinaRecibida(L) <- 
	.println("Medicamentos actualizados");
	-medicPend(_);
	+medicPend(L).

+!at(Ag, P) : at(Ag, P) <- 
	.println(Ag, " is at ",P);
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
-!go(P) <- 
	.println("¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿ WHAT A FUCK !!!!!!!!!!!!!!!!!!!!");
	.println("..........SOMETHING GOES WRONG......").                                        
	                                                                        

+!consumo(X) : battery(B) <-
	.print("-1 de batería: ", B);
	-battery(B);
	+battery(B-X).

//a lo mejor se puede poner otro plan de battery state para cuando sí este en el puesto de carga y se esté cargando.

+!batteryState : battery(B) & B < 50 & free <-
	.print("Mmmmmmmmmmmmmmmmmmmmme queda poca batería. Voy al puesto de cargaAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
	!at(auxiliar, charger);
	useCharger; //esto está en java así que ni idea de como activarlo y luego hay otra funcion que efectivamente carga la batería
	!cargarBateria;
	quitCharger;
	!at(auxiliar,afterCharger);
	!batteryState.

+!cargarBateria : battery(B) <-
	.print("CAAAARRRRGAAAAANNNDOOOOOOOOO.....");
	.wait(3000);
	-battery(B);
	+battery(288);
	.print("Estoy a tope jefe de equipo").


+!batteryState : battery(B) & B > 49 <-
	!batteryState.
                                     
+?time(T) : true
  <-  time.check(T).
