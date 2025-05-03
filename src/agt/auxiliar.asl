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

battery(288). //numero de casillas. Lo máximo que podría tener que recorrer andaría en unas 40 tirando por lo alto.
batteryMax(288).
contador(0).
free.
                 

 

medicPend([]). // Donde vamos a manejar los medicamentos que tiene que tomar owner
medicActual([]). // Donde vamos a manejar los medicamentos que lleva el robot actualmente

medicRep([]). //Lista de medicinas que tenemos que reponer por caducidad
medicStock([]). // Lista de medicinas que tenemos que reponer por cantidad de medicamentos

/* Plans */

// INICIALIZACIÓN
+!inicia : true <- 
    .print("Iniciando recordatorios de medicamentos...");
    .time(H, M, S);
    .findall(consumo(X,T,H,M,S), pauta(X,T), L);

    !iniciarContadores(L);
	!iniciarStock;
	!!alertaStock;
	!!batteryState.

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

// BATERÍA

+!consumo(X) : battery(B) <-
	.print("-1 de batería: ", B);
	-battery(B);
	+battery(B-X).

+!batteryState : battery(B) & B < 50 & free <-
	-free;
	.print("Me queda poca batería. Voy al puesto de carga");
	!at(auxiliar, waitCharger);
	// Si hay otro robot espero a que este libre
	
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

+!batteryState <-
	.wait(100);
	!batteryState.

+!comprobarCargadorLibre <-
	.send(enfermera,askOne, at(enfermera, charger)).

+!cargarBateria : battery(B) & batteryMax(BMax)<-
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

// STOCK

+!iniciarStock <- 
	getStock;
	.findall([Med,Q],stock(Med,Q),L);
	+stockActual(L).

+!actualizarStock <-
	-stockActual(L);
	!iniciarStock.

+!alertaStock: medicStock([]) <-
	.wait(1000);
	getStock;
	.findall([Med,Q],stock(Med,Q),Stock);
	!recorrerStock(Stock);
	!alertaStock.

+!alertaStock: true <-
	!alertaStock.



+!recorrerStock([[Med,Q]|Cdr]): medicStock(L) <- 
    if(Q<=2 & not member(Med,L)){
        -medicStock(L);
		+medicStock([Med|L]);
    }
	!hayQueRecoger;
	!recorrerStock(Cdr).

+!recorrerStock([]): medicStock(L) <- 
    true.



+!hayQueRecoger: medicStock([Car|Cdr]) & free <-
	-free;
    .println("Yendo a reponer stock");
    !at(auxiliar, delivery);
    .println("Stock recogido");
    .wait(1000);
    !at(auxiliar, kit);
	if(not .belief(open(kit))){
		open(kit);
	}
	?medicStock(L);
	!addStock(L);
	!actualizarStock;
    if(not .belief(close(kit))){
		close(kit);
	}
	!actualizarStock;
	+free.

+!hayQueRecoger: medicStock([Car|Cdr]) & not free <-
	.wait(1000);
	!hayQueRecoger.

+!hayQueRecoger: medicStock([]) <- true. // Si no hay ningun medicamento que reponer o suministrar

+!addStock([]) <-
	.println("Todo el stock repuesto");
	-medicStock(_);
	+medicStock([]).

+!addStock([Med|MedL]) : battery(B) & B > 0 <- 
	!consumo(1);
	.println("Reponiendo" , Med);
	reponerStock(Med);
	!addStock(MedL).


// CADUCIDAD

+!reponerMedicinas : battery(B) & B > 0 & medicRep(Med) & free <- 
	-free;
	!consumo(1);
    .println("Las medicinas ", Med, " van a caducar");
    .println("Yendo a la zona de entrega");
    !at(auxiliar, delivery);
	?medicRep(L);
	-medicRep(_);
	+medicRep([]);
	-medicActual(_);
	+medicActual(L);
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
+!reponerMedicinas: not free <-
	!reponerMedicinas.

+!reponerMedicina(Medicina): medicRep([]) & free <-
	.println("Estoy libre, va a caducar la medicina: ",Medicina);
	-medicRep(_);
	+medicRep([Medicina]);
	!reponerMedicinas.

+!reponerMedicina(Medicina): not medicRep([]) & free <-
	.println("Estoy libre, va a caducar la medicina: ",Medicina);
	?medicRep(L);
	-medicRep(_);
	+medicRep([Medicina|L]).

+!reponerMedicina(Medicina): medicRep([]) & not free <-
	.println("Esperando a estar libre para ir a reponer la medicina",Medicina);
	-medicRep(_);
	+medicRep([Medicina]);
	.wait(1000);
	!reponerMedicinas.

+!reponerMedicina(Medicina): not medicRep([]) & not free <-
	.println("Añadiendo medicina:",Medicina," a la lista de reposicion");
	?medicRep(L);
	-medicRep(_);
	+medicRep([Medicina|L]).

+!actualizarMedicina([]) <-
	.println("Toda la medicina repuesta");
	-medicActual(_);
	+medicActual([]);
	+free.

+!actualizarMedicina([Med|MedL]) : battery(B) & B > 0 <- 
	!consumo(1);
	.findall(caducidad(Med,Y), caducidad(Med,Y), U);
	.send(owner, untell, caducidad(Med,Y));
	.send(owner, achieve, cancelarPedido(Med));
    .send(enfermera, untell, caducidad(Med,Y));
    .send(owner, tell, U);
    .send(enfermera, tell, U);
	reponerMedCaducidad(Med);
	!actualizarStock;
	!actualizarMedicina(MedL).

// CÓDIGO BÁSICO

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
-!go(P) <- 
	.println("¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿ WHAT A FUCK !!!!!!!!!!!!!!!!!!!!");
	.println("..........SOMETHING GOES WRONG......").                                        

