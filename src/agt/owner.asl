/* Initial Beliefs */
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
connect(hall,livingroom, doorSal1).                       
connect(livingroom, hall, doorSal1).
connect(hallway,livingroom, doorSal2).
connect(livingroom, hallway, doorSal2).

/*Initial prescription beliefs*/
//Pautas iniciales de las que dispone el owner, medicamento y tiempo en segundos para su siguiente toma
pauta(paracetamol, 25). 
pauta(ibuprofeno, 30). 
pauta(dalsy, 25). 
pauta(frenadol, 40). 
pauta(aspirina, 50).

//Muestra la relacion entre la medicina y los segundos que hacen falta para que se caduque
caducidad(paracetamol, 50).
caducidad(ibuprofeno, 80).
caducidad(dalsy, 30).
caducidad(frenadol, 50).
caducidad(aspirina, 40).

medicPend([]). // Donde vamos a manejar los medicamentos que tiene que tomar owner
medicActualOwner([]). // Donde vamos a manejar los medicamentos que tiene el owner en el momento

/* Initial goals */

!send_pauta.

!aMiBola.

/*************************************************************************/
/*************************  INICIALIZACIÓN  ******************************/
/*************************************************************************/

+!send_pauta : true  <- // envia la informacion necesaria a los robots para su ejecución
	.findall(pauta(X,Y), pauta(X,Y), L);
	.findall(caducidad(X,Y), caducidad(X,Y), U);
	.print("Mi pauta: ", L);
	.send(enfermera, tell, L);
	.send(enfermera, tell, U);
	.send(auxiliar, tell, U);
	.send(enfermera,achieve,inicia);
	.send(auxiliar,achieve,inicia);
	!inicia.

+!inicia : true <- // Inicia la ejecución del agente. Crea las creencias necesarias y empieza a contar la caducidad
    .print("Iniciando recordatorios de medicamentos...");
    .time(H, M, S);
    .findall(consumo(X,T,H,M,S), pauta(X,T), L);
	.findall(caducidad(X,Y), caducidad(X,Y), U);
	!iniciarCaducidad(U);
    !iniciarContadores(L);
    !tomarMedicina.

+!iniciarCaducidad([caducidad(X,_)|Cdr]) <- // Empieza el contador de caducidades
	!!contadorCaducidad(X);
	!iniciarCaducidad(Cdr).

+!iniciarCaducidad([]) <- 
	.print("Iniciacion de la caducidad completada").

+!iniciarContadores([consumo(Medicina,T,H,M,S)|Cdr]) <- // Crea las creencias de consumo, las que marcan cuando se debe tomar el owner la medicacion
    if(S+T>=60){ 
		+consumo(Medicina,T,H,M+1,S+T-60);
		.print(consumo(Medicina,T,H,M+1,S+T-60));	
	}else{
		+consumo(Medicina,T,H,M,S+T);
		.print(consumo(Medicina,T,H,M,S+T));
	}
	
    !iniciarContadores(Cdr).
+!iniciarContadores([]) <- .print("Inicialización completada").

+!contadorCaducidad(M) : caducidad(M, T) & not pedidoReposicion(M) <-  // Plan que se ejecuta contantemente para la comprobacion de caducidades
    if(T<15){ // Si el tiempo es menor de 15 manda al auxicojaliar que  reponga la medicina.
        .send(auxiliar, achieve, reponerMedicina(M));
        +pedidoReposicion(M);  // Marcar que ya se pidió
    } 
    -caducidad(M, T);
    +caducidad(M, T-1);
    .wait(1000);
    .print("Caducidad de ", M, " : ", T);
    !contadorCaducidad(M).

+!contadorCaducidad(M) : caducidad(M, T) & pedidoReposicion(M) <- 
    -caducidad(M, T);
    +caducidad(M, T-1);
    .wait(1000);
    .print("Caducidad de ", M, " : ", T);
    !contadorCaducidad(M).

+!cancelarPedido(M) <- // Elimina la creencia de pedido reposicion para la medicina M, repuesta por el auxiliar
	-pedidoReposicion(M).

+!addPauta(pauta(Medicacion,Tiempo)) <- // Añade dinamicamente una pauta definida por el usuario
	.println("Se me ha añadido la pauta: ",Medicacion," tiempo: ",Tiempo);
	.time(H,M,S);
	.send(enfermera,achieve,addPauta(pauta(Medicacion,Tiempo)));
	+pauta(Medicacion,Tiempo);
	+consumo(Medicacion,Tiempo,H,M,S).

+!deletePauta(pauta(Medicacion,_)) <- // Elimina dinamicamente una pauta.
	.println("Se ha eliminado la pauta: ",Medicacion);
	.time(H,M,S);
	.send(enfermera,achieve,deletePauta(pauta(Medicacion,_)));
	-pauta(Medicacion,_);
	-consumo(Medicacion,_,H,M,S).

/*************************************************************************/
/**********************  MOVIMIENTO ALEATORIO  ***************************/
/*************************************************************************/
 
+!aMiBola <-  // Movimiento aleatorio princiapk del owner, realiza sit hasta que se espera un tiempo aleatorio, posteriormente va a por la medicina
   	!!sit;
	.random(X); .wait(X*10000+2000);
   	.print("Voy yo a por la medicina");
	!goToMedicina.
	
+!goToMedicina: busy <- // El owner va a por la medicina aunque este ejecutando el plan sit
	 .println("Estoy ocupado pero voy a por la medicina igual");
	 .drop_desire(sit);
	 -busy;
	 !aPorMedicina;
	 !aMiBola.

+!goToMedicina: not busy <- // Si el owner no esta ocupado va a por la medicina y psoteriormente realiza el movimiento aleatorio
	 .println("No estoy ocupado voy a por la medicina"); 
	 !aPorMedicina;
	 !aMiBola.

/*************************************************************************/
/**********************   IR A POR MEDICINA  *****************************/
/*************************************************************************/

// Plan que comprueba si es hora de ir a por la medicina, cuando el tiempo de tomar la medicina es dentro de 7 segundos se activa y la añada a la lista
+!tomarMedicina: pauta(Medicina,T) & consumo(Medicina,T,H,M,S) & .time(H,MM,SS) & ((MM == M & 7 >= S-SS ) | (M == MM+1 & S<7 & 7 >= (60-SS)+(S)))  & medicPend(Med) <- // Funciona por que S siempre es anterior
	.println("Me debo tomar ",Medicina, " a las: ",H,":",M,":",S);
	!addMedicina(Medicina);
    .abolish(consumo(Medicina,T,H,M,S));
	if(S+T>=60){ 
		+consumo(Medicina,T,H,M+1,S+T-60);	
	}else{
		+consumo(Medicina,T,H,M,S+T);
	}
	.belief(consumo(Medicina,_,_,MMM,SSS));
	.println("Actualizado consumo a min: ",MMM," seg: ",SSS);
    !tomarMedicina.


+!tomarMedicina <- // Mantiene el plan vivo mientras no tenga que ir a por la medicina
    .wait(10);
    !tomarMedicina.

+!aPorMedicina: not busy  <- // Va por la medicina en medicPend, la coge toda y se la toma.
	+busy;
	!at(owner, kit);
	.send(enfermera,achieve,cancelarMedicacion);
	if(not .belief(open(kit))){
		open(kit);
	}
	.belief(medicPend(L));
	!cogerTodaMedicina(L);
	!consumirMedicina;
	.abolish(medicPend(L));
	+medicPend([]);
	if(not .belief(close(kit))){
		close(kit);
	}
	!enviarMedicinaPendiente;
	-busy.

+!aPorMedicina: busy <- // Si esta coupado mantiene vivo el plan
	true.

+!cancelarMedicacion: busy & .desire(aPorMedicina) <- // Si el owner estaba llendo a por la medicina y el robot llega antes, este para la accion
	.print("Me prohiben ir a por la medicacion, estaba yendo a por ella");
	.drop_desire(aPorMedicina);
	-busy;
	!aMiBola.

+!cancelarMedicacion <- // Plan alternativo por si el robot manda la accion de cancelarMedicacion pero el owner no estaba yendo.
	.print("Me prohiben ir a por la medicacion y no estaba yendo yo").

+!enviarMedicinaPendiente: medicPend(L) <- // Envia la actualizacion de medicinasPendientes al robot
	.send(enfermera,achieve,medicinaRecibida(L)).

+!consumirMedicina: medicActualOwner([Car|Cdr]) <- // Consume la medicina Car y actualiza la lista medicActualOwner
	.println("Tomando ", Car);
	-medicActualOwner(_);
	+medicActualOwner(Cdr);
	!consumirMedicina.

+!consumirMedicina: medicActualOwner([]) <- 
	.println("Me he tomado toda la medicina").	


+!cogerTodaMedicina([Car|Cdr]) <- // Coge las medicinas del kit 
		.println("Cojo la medicina ",Car);
		getMedicina(Car);
		.belief(medicActualOwner(L));
		-medicActualOwner(_);
		+medicActualOwner([Car|L]);
		!cogerTodaMedicina(Cdr).

+!cogerTodaMedicina([]): medicActualOwner(L) <- // Cuando ha cogido todas las medicinas, envia a la enfermera las medicinas que ha tomado
		.println("He cogido toda la medicina");
		.send(enfermera,tell,medicActualOwner(L)).

+!medicinaRecibida(L) <- // Actualiza la lista de medPend cuando el robot le ha suministrado medicinas
	.println("Medicamentos actualizados");
	-medicPend(_);
	+medicPend(L).

+!addMedicina(Medicina): medicPend(Med) <- // Añade la medicina Medicina a la lista medicPend
	.concat(Med,[Medicina],L);
	-medicPend(_);
	+medicPend(L).

/*************************************************************************/
/*************************  CÓDIGO BÁSICO  *******************************/
/*************************************************************************/

+!sit : .my_name(Ag) & not busy <- 
	+busy; 
	.println("Owner va a la nevera a coger una cerveza.");
	.wait(1000);
	!at(Ag, fridge);
	.println("Owner tiene hambre y está en la nevera cogiendo algo");
	.wait(20);
	!at(Ag, chair3);
	sit(chair3);
	.wait(40);
	!at(Ag, chair4);
	sit(chair4);
	.wait(40);
	!at(Ag, chair2);
	sit(chair2);
	.wait(40);
	!at(Ag, chair1);
	sit(chair1);
	.wait(40);
	!at(Ag, sofa);
	sit(sofa);
	.wait(100);
	-busy.

+!sit : .my_name(Ag) & busy <-
	.println("Owner está haciendo algo ahora y no puede ir a la nevera");
	.wait(300);
	!sit.

+!at(Ag, P) : at(Ag, P) <- 
	.println("Owner está en ",P);
	.wait(500).
+!at(Ag, P) : not at(Ag, P) <- 
	.println("Yendo a ", P);
	!go(P);                                        
	.println("Comprobando si está en ", P);
	!at(Ag, P).            
	                                                   
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomAg) <-                             
	move_towards(P).  
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & atDoor(Door) <-                   
	move_towards(P); 
	!go(P).       
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & not atDoor(Door) <-
	move_towards(Door); 
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

+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP <-
	move_towards(P).                                                          
-!go(P) <- .println("Algo va mal......").
	                                                                        





