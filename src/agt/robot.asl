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

free. // Muestra si la enfermera esta libre
                 
battery(288). // Bateria actual de la enfermeera
batteryMax(288). // Bateria maxima de la enfermera

medicPend([]). // Donde vamos a manejar los medicamentos que tiene que tomar owner
medicActual([]). // Donde vamos a manejar los medicamentos que lleva el robot actualmente
contador(0). 	// numero de veces que el auxiliar ha salido de la bateria antes de tiempo


/* Plans */

/*************************************************************************/
/*************************  INICIALIZACIÓN  ******************************/
/*************************************************************************/

+!inicia : true <- // Inicia todas las creencias necesarias y inicia planes necesarios.
    .print("Iniciando recordatorios de medicamentos...");
    .time(H, M, S);
    .findall(consumo(X,T,H,M,S), pauta(X,T), L);
    !iniciarContadores(L);
	!iniciarStock;
    !!tomarMedicina;
	!!batteryState.

+!iniciarContadores([consumo(Medicina,T,H,M,S)|Cdr]) <- // Añade creencias de consumo al agente
    if(S+T>=60){ 
		+consumo(Medicina,T,H,M+1,S+T-60);
		.print(consumo(Medicina,T,H,M+1,S+T-60));	
	}else{
		+consumo(Medicina,T,H,M,S+T);
		.print(consumo(Medicina,T,H,M,S+T));
	}
	
    !iniciarContadores(Cdr).
+!iniciarContadores([]) <- .print("Inicialización completada").

+!addPauta(pauta(Medicacion,Tiempo)) <- // Añade dinamicamente una pauta definida por el usuario
	.println("Se me ha añadido la pauta: ",Medicacion," tiempo: ",Tiempo);
	.time(H,M,S);
	+pauta(Medicacion,Tiempo);
	+consumo(Medicacion,Tiempo,H,M,S).

+!deletePauta(pauta(Medicacion,_)) <- // Elimina dinamicamente una pauta.
	.println("Se ha eliminado la pauta: ",Medicacion);
	.time(H,M,S);
	-pauta(Medicacion,_);
	-consumo(Medicacion,_,H,M,S).

+!iniciarStock <-  //Añadimos creencia de stock de medicinas
	getStock;
	.findall([Med,Q],stock(Med,Q),L);
	+stockActual(L).

/*************************************************************************/
/***************************  BATERIA  ***********************************/
/*************************************************************************/

+!consumo(X) : battery(B) <- // Reduce la batería del agente en X
	.print("-1 de batería: ", B);
	-battery(B);
	+battery(B-X).


+!batteryState: battery(B) & B <=0 <- // Si se queda sin bateria, manda mensaje
	.println("SIN BATERIA");
	.wait(3000);
	!batteryState.

+!batteryState : battery(B) & B < 100 & free <- // Si la batería de la enfermera es menor que 100, voy al puesto de carga
	-free;
	.print("Me queda poca batería. Voy al puesto de carga");
	!at(enfermera, waitCharger);
	!comprobarCargadorLibre;
	
	while(.belief(at(auxiliar,charger))){
		.wait(100);
		-at(auxiliar,charger);
		!comprobarCargadorLibre;
	}
	!at(enfermera, charger);
	useCharger; //esto está en java así que ni idea de como activarlo y luego hay otra funcion que efectivamente carga la batería
	!cargarBateria;
	quitCharger;
	!at(enfermera,afterChargerRobot);
	+free;
	!batteryState.

+!batteryState : battery(B) & B < 100 & not free <- // Si no esta libre deja vivo el plan
	.println("Estoy ocupado, todavia no puedo ir a cargar...");
	.wait(1000);
	!batteryState.

+!batteryState  <- // En otro caso sigue vivo el plan
	!batteryState.

+!comprobarCargadorLibre <- // Comprueba si el auxiliar esta libre
	.send(auxiliar,askOne, at(auxiliar, charger)).

+!cargarBateria : battery(B) & batteryMax(BMax)<- // Gasta 3 segundos para cargar la bateria al completo
	.print("Cargando.....");
	.wait(3000);
	-battery(B);
	+battery(BMax);
	.print("He completado mi carga").
	
+!cancelarCargarBateria: contador(T) & batteryMax(B) <- // Cancela la carga y aumenta su contador, si este es de 3 reduce su carga maxima
	.println("Me han cancelado la carga, me quito un 5%");
	.drop_desire(cargarBateria);
	-contador(_);
	+contador(T+1);
	if(T==3){ //Caso que queremos decrementar
		-batteryMax(_);
		+batteryMax(B*0.95);
		-contador(_);
		+contador(0);
	}.
                      
/*************************************************************************/
/***************************  STOCK  *************************************/
/*************************************************************************/


+!actualizarStock <- // Actualizamos la creencia de stockActual de la enfermera
	-stockActual(L);
	!iniciarStock.

/*************************************************************************/
/************************** DAR MEDICINA *********************************/
/*************************************************************************/

+!tomarMedicina: battery(B) & battery <= 0 <- // Si no tiene bateria suficiente para ir a por la medicina
	.println("SIN BATERIA CANCELANDO LA ACCION tomarMedicina").

//Plan que comprueba si es hora de ir a por la medicina, cuando el tiempo de tomar la medicina es dentro de 7 segundos se activa y va al kit a cogerla
+!tomarMedicina: pauta(Medicina,T) & consumo(Medicina,T,H,M,S) & .time(H,MM,SS) & ((MM == M & 7 >= S-SS ) | (M == MM+1 & S<7 & 7 >= (60-SS)+(S)))  & medicPend(Med) <- // Funciona por que S siempre es anterior
	.println("Hora de ir yendo a por la medicación...");
	.println("Owner debe tomar ",Medicina, " a las: ",H,":",M,":",S);
	.println("Voy a ir yendo a por ", Medicina, " a las: ",H,":",M,":",SS);	
	!addMedicinaPendiente(Medicina);
	!!aPorMedicina(Medicina,H,M,S);
    .abolish(consumo(Medicina,T,H,M,S));
	if(S+T>=60){ 
		+consumo(Medicina,T,H,M+1,S+T-60);	
	}else{
		+consumo(Medicina,T,H,M,S+T);
	}
	.belief(consumo(Medicina,_,_,MMM,SSS));
	.println("Actualizado consumo a min: ",MMM," seg: ",SSS);
    !tomarMedicina.

+!tomarMedicina <- // Si no hay ninguna medicina que tomar, mantenemos vivo el plan
    .wait(10);
    !tomarMedicina.


+!aPorMedicina(_,_,_,_): battery(B) & battery <= 0 <- // Si no tiene bateria suficiente para ir a por la medicina
	.println("SIN BATERIA CANCELANDO LA ACCION aPorMedicina").

+!aPorMedicina(Medicina,H,M,S): free <- // Si esta libre va al kit a coger la medicina y a llevarsela al owner
	-free;
	.println("A por medicina");
	!at(enfermera, kit);
	.send(owner,achieve,cancelarMedicacion);
	if(not .belief(open(kit))){
		open(kit);
	}
	.belief(medicPend(L));
	!cogerTodaMedicina(L);
	.abolish(medicPend(L));
	+medicPend([]);
	!enviarMedicinaPendiente;
	if(not .belief(close(kit))){
		close(kit);
	}
	!comprobarHora(L,H,M,S);
	+free.


+!aPorMedicina(Medicina,H,M,S): not free & .desire(comprobarTomaOwner) & not .desire(aPorMedicina)<- // Si esta comprobando si se ha tomado la medicina, sigue vivo el plan
		.println("Comprobando que owner se ha tomado la medicacion, posteriormente llevare la medicina " ,Medicina);
		.wait(3000);
		!aPorMedicina(Medicina,H,M,S).

+!aPorMedicina(Medicina,_,_,_): not free  <- // Si no esta libre y no esta comprobando medicina que se ha tomado el owner, asusmimos que esta llendo a por la medicina
		.println("Añadido ", Medicina, " a la lista").


+!comprobarHora(_,_,_,_): battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO comprobarHora").

+!comprobarHora([Med|MedL],H,M,S) <-  // Va hacia el owner, mientras no sea la hora perfecta para tomarse la medicina, la enfermera sigue al owner
		!at(enfermera, owner);	
		.time(HH,MM,SS);
		if(SS<S) {    
			.print("Esperando a la hora perfecta... Hora perfecta: ",H,":",M,":",S);
			.print("Esperando en hora actual: ",HH,":",MM,":",SS);
			!comprobarHora([Med|MedL],H,M,S);
     	}else{
			!darMedicina([Med|MedL],H,M,S);
		}.

+!comprobarHora(_,_,_,_) <-
	.println("No hora que comprobar").

+!enviarMedicinaPendiente: medicPend(L) <- // Informa al owner sobre las medicaciones pendientes actueales que tiene que tomar
	.send(owner,achieve,medicinaRecibida(L)). 

+!darMedicina(_,_,_,_): battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO darMedicina").

+!darMedicina([Med|MedL],H,M,S) <- // Le da la medicina Med al owner
	!consumo(2);
	.time(HH,MM,SS);
	.println("Dando al owner la medicina: ", Med, " a la hora: ",HH,":",MM,":",SS);
	!darMedicina(MedL,H,M,S).

+!darMedicina([],H,M,S) <- // Ha dado toda la medicina al owner
	.println("Toda la medicina dada");
	-medicActual(_);
	+medicActual([]).

+!addMedicinaPendiente(Medicina): medicPend(Med) <- // Añade la medicina Medicina a la lista medicPend
	.concat(Med,[Medicina],L);
	-medicPend(_);
	+medicPend(L).

+!addMedicinaActual(Medicina): medicActual(Med) <- // Añade la medicina Medicina a la lista medicActual
	.concat(Med,[Medicina],L);
	-medicActual(_);
	+medicActual(L).

+!cogerTodaMedicina(_): battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO cogerTodaMedicina").

+!cogerTodaMedicina([Car|Cdr]) <- // Coge las medicinas del kit
	!consumo(2);
	.println("Cojo la medicina ",Car);
	getMedicina(Car);
	!addMedicinaActual(Car);
	!cogerTodaMedicina(Cdr).

+!cogerTodaMedicina([]) <-
	.println("He cogido toda la medicina");
	!actualizarStock.

/*************************************************************************/
/******************** COMPROBAR MEDICINA TOMADA **************************/
/*************************************************************************/

+!cancelarMedicacion: battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO cancelarMedicacion").

+!cancelarMedicacion: free <- // Si esta libre y le llega el informe de que el owner ha ido a tomarse la medicina
	.print("Me prohiben ir a por la medicacion, estoy libre");
	!comprobarTomaOwner.

+!cancelarMedicacion: not free & medicActual([])  <- // Si no esta libre, cancela el aPorMedicina y va a comprobar las medicinas
	.print("Me prohiben ir a por la medicacion");
	.drop_intention(aPorMedicina(_,_,_,_));
	+free;
	!comprobarTomaOwner.

+!cancelarMedicacion: not free & not medicActual([]) <- 
	.print("Me prohiben ir a por la medicacion pero tengo medicina que entregar al owner");
	!comprobarTomaOwner.

+!comprobarTomaOwner: battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO comprobarTomaOwner").

+!comprobarTomaOwner: free <-  // Si esta libre para ir a comprobar si el owner se ha tomado la medicacion, va al kit y lo comprueba
	-free;
	.println("El owner ha cogido la medicina, comprobando si se la ha tomado...");
	!at(enfermera,kit);
	!comprobarStock;
	+free.

+!comprobarTomaOwner: not free <- // Si no esta libre para ir a comprobar si el owner se ha tomado la medicacion, mantiene vivo el plan
	.println("Esperando a estar libre para comprobar que el owner se ha tomado la medicacion...");
	.wait(1000);
	!comprobarTomaOwner.

+!comprobarStock: battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO comprobarStock").

+!comprobarStock: not medicActualOwner(L) <- // Espera a que el owner le diga que ha tomado para comprobar posteriormente si realmente se lo ha tomado
	.print("Esperando a que owner me diga que medicacion ha tomado...");
	.wait(500);
	!comprobarStock.

+!comprobarStock: medicActualOwner(L) <- // Plan principal, coge el stock nuevo y lo compara con el antiguo(el que tenia en sus creencias)
	.println(L);
	getStock;
	.findall([Med,Q],stock(Med,Q),StockNuevo);
	!comprobarMedicinas(L,StockNuevo);
	.abolish(medicActualOwner(_));
	!actualizarStock.

+!comprobarMedicinas(_,_): battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO comprobarMedicinas").

+!comprobarMedicinas([Med|Cdr],StockNuevo) <- // Por cada medicina que ha cogido el owner comprobamos
	!comprobarMedicina(Med,StockNuevo);
	!comprobarMedicinas(Cdr,StockNuevo).

+!comprobarMedicinas([],StockNuevo) <- .print("Todas medicinas comprobadas").


+!comprobarMedicina(_,_): battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO comprobarMedicina").

+!comprobarMedicina(MedicinaTomada,[[MedicinaTomada,Q1]|Cdr1]) <- // 
	.belief(stockActual(L));
	!comprobarStockMedicina(MedicinaTomada,Q1,L).
	
+!comprobarMedicina(MedicinaTomada,[[_,_]|Cdr1]) <- // Si el stock ha bajado, significa que el owner se lo ha tomado, si es al contrario, se aviso que no se ha tomado la medicacion
	!comprobarMedicina(MedicinaTomada,Cdr1);
	if(Q1 < Q2){
		.print("Owner se ha tomado medicina ",MedicinaTomada);
	}else{
		.print("AVISO! Owner no se ha tomado  ", MedicinaTomada);
	}.

+!comprobarStockMedicina(_,_): battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO comprobarStockMedicina").

+!comprobarStockMedicina(MedicinaTomada,Q1,[[_,_]|Cdr]) <- 
	!comprobarStockMedicina(MedicinaTomada,Q1,Cdr).

+!comprobarStockMedicina(MedicinaTomada,Q1,[]) <- 
	true.

+!medicinaRecibida(_,_): battery(B) & B<=0 <-
	.println("SIN BATERIA, CANCELANDO medicinaRecibida").

+!medicinaRecibida(L) <- // Actualiza la lista de medPend cuando el owner le ha informa sobre las medicinas que ha tomado
	.println("Medicamentos actualizados");
	-medicPend(_);
	+medicPend(L).

/*************************************************************************/
/*************************  CÓDIGO BÁSICO  *******************************/
/*************************************************************************/

+!at(Ag, P) : at(Ag, P) <- 
	.println(Ag, " está en ",P);
	.wait(500).
+!at(Ag, P) : not at(Ag, P) <-   
	!go(P);                                        
	!at(Ag, P).            
	                                                   
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomAg) <- 
	!consumo(1);
	move_towards(P).  
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & not atDoor(Door) <-
	!consumo(1);
	move_towards(Door); 
	!go(P).                     
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & not atDoor(Door) <- 
	!consumo(1);
	move_towards(P); 
	!go(P).       
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  not connect(RoomAg, RoomP, _) & connect(RoomAg, Room, DoorR) &
		  connect(Room, RoomP, DoorP) & atDoor(DoorR) <-
	!consumo(1);
	move_towards(DoorP); 
	!go(P). 
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  not connect(RoomAg, RoomP, _) & connect(RoomAg, Room, DoorR) &
		  connect(Room, RoomP, DoorP) & not atDoor(DoorR) <-
	!consumo(1);
	move_towards(DoorR); 
	!go(P). 
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP <-
	!consumo(1);
	move_towards(P).     

-!go(P): battery(B) & B <= 0 <- 
	.wait(3000);
	.println("¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿BIG ERROR?????????????????");
	.println("..........I DONT HAVE BATTERY LEFT......").                                                   
-!go(P) <- 
	.println("¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿ WHAT A FUCK !!!!!!!!!!!!!!!!!!!!");
	.println("..........SOMETHING GOES WRONG......").                                                                                                            
