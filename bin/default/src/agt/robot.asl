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

// initially, robot is free
free.
                 

 

medicPend([]). // Donde vamos a manejar los medicamentos que tiene que tomar owner
medicActualNurse([]). // Donde vamos a manejar los medicamentos que lleva el robot actualmente


/* Plans */


+!inicia : true <- 
    .print("Iniciando recordatorios de medicamentos...");
    .time(H, M, S);
    .findall(consumo(X,T,H,M,S), pauta(X,T), L);
    !iniciarContadores(L);
    !tomarMedicina.
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


/* MISMA HORA Y MINUTO*/						
+!tomarMedicina: pauta(Medicina,T) & consumo(Medicina,T,H,M,S) & .time(H,MM,SS) & ((MM == M & 15 >= S-SS ) | (M == MM+1 & S<15 & 15 >= (60-SS)+(S)))  & medicPend(Med) <- // Funciona por que S siempre es anterior
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


/* NADA QUE TOMAR */
+!tomarMedicina <- 
    .wait(10);
    !tomarMedicina.

+!aPorMedicina(Medicina,H,M,S): free[source(self)]<-
		.println("A por medicina");
    	-free[source(self)];
		!at(enfermera, fridge);
		.send(owner,achieve,cancelarMedicacion);
		open(fridge);
		.belief(medicPend(L));
		!cogerTodaMedicina(L);
		.abolish(medicPend(L));
		+medicPend([]);
		close(fridge);
		!enviarMedicinaPendiente;
		!comprobarHora(L,H,M,S);
		+free[source(self)].


+!aPorMedicina(Medicina,H,M,S): not free[source(self)] & .desire(comprobarTomaOwner) & not .desire(aPorMedicina)<-
		.println("No he terminado de comprobar si owner ha tomado medicina, suspendiendo accion");
		.drop_intention(comprobarTomaOwner);
		+free;
		!aPorMedicina(Medicina,H,M,S);
		!comprobarTomaOwner.

+!aPorMedicina(Medicina,_,_,_): not free[source(self)]  <-
		.println("Añadido ", Medicina, " a la lista").

+!addPauta(pauta(Medicacion,Tiempo)) <-
	.println("Se me ha añadido la pauta: ",Medicacion," tiempo: ",Tiempo);
	.time(H,M,S);
	+pauta(Medicacion,Tiempo);
	+consumo(Medicacion,Tiempo,H,M,S).

+!deletePauta(pauta(Medicacion,_)) <-
	.println("Se ha eliminado la pauta: ",Medicacion);
	.time(H,M,S);
	-pauta(Medicacion,_);
	-consumo(Medicacion,_,H,M,S).

+!cancelarMedicacion: medicActualNurse([]) <-
	.print("Me prohiben ir a por la medicacion");
	.drop_intention(aPorMedicina(_,_,_,_));
	+free;
	!comprobarTomaOwner.

+!cancelarMedicacion: not medicActualNurse([]) <-
	.print("Me prohiben ir a por la medicacion pero tengo medicina que entregar al owner");
	!comprobarTomaOwner;
	+free.

+!comprobarTomaOwner: not free <- 
	.println("El owner ha cogido la medicina, comprobando si se la ha tomado... ESPERANDO A ESTAR LIBRE");
	.wait(1000);
	!comprobarTomaOwner.

+!comprobarTomaOwner: free <- 
	-free;
	.println("El owner ha cogido la medicina, comprobando si se la ha tomado...");
	!at(enfermera,owner);
	.println("LLEGADO");
	.send(owner,askOne,medicActualOwner(L),A,100);
	+A;
	+free.

+medicActualOwner([]) <-
	.println("Detectado que owner ha tomado medicina");
	-medicActualOwner(_).
+medicActualOwner(L) <-
	.println("Owner no se ha tomado medicina!! ",L);
	-medicActualOwner(_).



+!comprobarHora([Med|MedL],H,M,S) <- 
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

+!enviarMedicinaPendiente: medicPend(L) <-
	.send(owner,achieve,medicinaRecibida(L)).

+!darMedicina([],H,M,S) <-
	.println("TODA LA MEDICINA TOMADA");
	-medicActualNurse(_);
	+medicActualNurse([]).

+!darMedicina([Med|MedL],H,M,S) <-
	.time(HH,MM,SS);
	.println("Dando al owner la medicina: ", Med, " a la hora: H:",HH,":",MM,":",SS);
	!darMedicina(MedL,H,M,S).


+!addMedicinaPendiente(Medicina): medicPend(Med) <-
	.concat(Med,[Medicina],L);
	-medicPend(_);
	+medicPend(L).

+!addMedicinaActual(Medicina): medicActualNurse(Med) <-
	.concat(Med,[Medicina],L);
	-medicActualNurse(_);
	+medicActualNurse(L).




+!cogerTodaMedicina([Car|Cdr]) <-
		.println("Cojo la medicina ",Car);
		getMedicina(Car);
		!addMedicinaActual(Car);
		!cogerTodaMedicina(Cdr).

+!cogerTodaMedicina([]) <-
		.println("He cogido toda la medicina").

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
	                                                   
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomAg) <- 
	move_towards(P).  
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & not atDoor(Door) <-
	move_towards(Door); 
	!go(P).                     
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & not atDoor(Door) <- 
	move_towards(P); 
	!go(P).       
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  not connect(RoomAg, RoomP, _) & connect(RoomAg, Room, DoorR) &
		  connect(Room, RoomP, DoorP) & atDoor(DoorR) <-
	move_towards(DoorP); 
	!go(P). 
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  not connect(RoomAg, RoomP, _) & connect(RoomAg, Room, DoorR) &
		  connect(Room, RoomP, DoorP) & not atDoor(DoorR) <-
	move_towards(DoorR); 
	!go(P). 
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP <- //& not atDoor <-
	move_towards(P).                                                          
-!go(P) <- 
	.println("¿¿¿¿¿¿¿¿¿¿¿¿¿¿¿ WHAT A FUCK !!!!!!!!!!!!!!!!!!!!");
	.println("..........SOMETHING GOES WRONG......").                                        
	                                                                        

                                     
+?time(T) : true
  <-  time.check(T).
