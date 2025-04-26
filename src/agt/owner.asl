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
pauta(paracetamol, 25). 
pauta(ibuprofeno, 30). 
pauta(dalsi, 25). 
pauta(frenadol, 40). 
pauta(aspirina, 50).

//Caducidades
caducidad(paracetamol, 50).
caducidad(ibuprofeno, 80).
caducidad(dalsi, 30).
caducidad(frenadol, 100).
caducidad(aspirina, 100).

medicPend([]). // Donde vamos a manejar los medicamentos que tiene que tomar owner
medicActualOwner([]). // Donde vamos a manejar los medicamentos que tiene el owner en el momento
/* Initial goals */

//Owner will send his prescription to the robot
// Owner will simulate the behaviour of a person 
// We need to characterize their digital twin (DT)
// Owner must record the DT data periodically 
// Owner must access the historic data of such person
// Owner will act randomly according to some problems
// Owner will usually act with a behaviour normal
// Owner problems will be activated by some external actions
// Owner problems will randomly be activated on time
// Owner will dialog with the nurse robot 
// Owner will move randomly in the house by selecting places





!send_pauta.

!aMiBola.


// Initially Owner could be: sit, opening the door, waking up, walking, ...
//!sit.   			
//!check_bored. 

//+!init <- !sit ||| !open ||| !walk ||| !wakeup ||| !check_bored.

+!send_pauta : true  <-
	.findall(pauta(X,Y), pauta(X,Y), L);
	.findall(caducidad(X,Y), caducidad(X,Y), U);
	.print("Mi pauta: ", L);
	.send(enfermera, tell, L);
	.send(enfermera, tell, U);
	.send(auxiliar, tell, L);
	.send(auxiliar, tell, U);
	.send(enfermera,achieve,inicia);
	.send(auxiliar,achieve,inicia);
	!inicia.


+!inicia : true <- 
    .print("Iniciando recordatorios de medicamentos...");
    .time(H, M, S);
    .findall(consumo(X,T,H,M,S), pauta(X,T), L);
	.findall(caducidad(X,Y), caducidad(X,Y), U);
	!iniciarCaducidad(U);
    !iniciarContadores(L);
    !tomarMedicina.


+!iniciarCaducidad([caducidad(X,_)|Cdr]) <-
	!!contadorCaducidad(X);
	!iniciarCaducidad(Cdr).

+!iniciarCaducidad([]) <- 
	.print("Iniciacion de la caducidad completada").

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

+!contadorCaducidad(M) : caducidad(M, T) & not pedidoReposicion(M) <- 
    if(T<15){
		.send(auxiliar, achieve, addMedicinaReponer(M));
        .send(auxiliar, achieve, reponerMedicina(M));
        +pedidoReposicion(M);  // Marcar que ya se pidió
    } 
    -caducidad(M, T);
    +caducidad(M, T-1);
    .wait(1000);
    .print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", M, "tiempo: ", T);
    !contadorCaducidad(M).

+!contadorCaducidad(M) : caducidad(M, T) & pedidoReposicion(M) <- 
    -caducidad(M, T);
    +caducidad(M, T-1);
    .wait(1000);
    .print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA", M, "tiempo: ", T);
    !contadorCaducidad(M).

+!addPauta(pauta(Medicacion,Tiempo)) <-
	.println("Se me ha añadido la pauta: ",Medicacion," tiempo: ",Tiempo);
	.time(H,M,S);
	.send(enfermera,achieve,addPauta(pauta(Medicacion,Tiempo)));
	+pauta(Medicacion,Tiempo);
	+consumo(Medicacion,Tiempo,H,M,S).

+!deletePauta(pauta(Medicacion,_)) <-
	.println("Se ha eliminado la pauta: ",Medicacion);
	.time(H,M,S);
	.send(enfermera,achieve,addPauta(pauta(Medicacion,_)));
	-pauta(Medicacion,_);
	-consumo(Medicacion,_,H,M,S).


/* MISMA HORA Y MINUTO*/						
+!tomarMedicina: pauta(Medicina,T) & consumo(Medicina,T,H,M,S) & .time(H,MM,SS) & ((MM == M & 15 >= S-SS ) | (M == MM+1 & S<15 & 15 >= (60-SS)+(S)))  & medicPend(Med) <- // Funciona por que S siempre es anterior
	.println("Hora de ir yendo a por la medicación...");
	.println("Owner debe tomar ",Medicina, " a las: ",H,":",M,":",S);
	.println("Voy a ir yendo a por ", Medicina, " a las: ",H,":",M,":",SS);	
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


/* NADA QUE TOMAR */
+!tomarMedicina <- 
    .wait(10);
    !tomarMedicina.

+!aPorMedicina: not busy  <-
	+busy;
	!at(owner, kit);
	.send(enfermera,achieve,cancelarMedicacion);
	open(kit); 
	.belief(medicPend(L));
	!cogerTodaMedicina(L);
	!consumirMedicina;
	.abolish(medicPend(L));
	+medicPend([]);
	close(kit);
	!enviarMedicinaPendiente;
	-busy.


+!cancelarMedicacion: busy & .desire(aPorMedicina) <-
	.print("Me prohiben ir a por la medicacion, estaba yendo a por ella");
	.drop_desire(aPorMedicina);
	-busy;
	!aMiBola.

+!cancelarMedicacion <-
	.print("Me prohiben ir a por la medicacion y no estaba yendo yo").

+!enviarMedicinaPendiente: medicPend(L) <-
	.send(enfermera,achieve,medicinaRecibida(L)).



+!consumirMedicina: medicActualOwner([Car|Cdr]) <-
	.println("Tomando ", Car);
	-medicActualOwner(_);
	+medicActualOwner(Cdr);
	!consumirMedicina.

+!consumirMedicina: medicActualOwner([]) <-
	.println("Me he tomado toda la medicina").	


+!cogerTodaMedicina([Car|Cdr]) <-
		.println("Cojo la medicina ",Car);
		getMedicina(Car);
		.belief(medicActualOwner(L));
		-medicActualOwner(_);
		+medicActualOwner([Car|L]);
		!cogerTodaMedicina(Cdr).

+!cogerTodaMedicina([]): medicActualOwner(L) <-
		.println("He cogido toda la medicina");
		.send(enfermera,tell,medicActualOwner(L)).

/* NADA QUE TOMAR */
+!tomarMedicina <- 
    .wait(10);
    !tomarMedicina.

+!medicinaRecibida(L) <- 
	.println("Medicamentos actualizados");
	-medicPend(_);
	+medicPend(L).

+!addMedicina(Medicina): medicPend(Med) <-
	.concat(Med,[Medicina],L);
	-medicPend(_);
	+medicPend(L).

+!aMiBola <- 
   	!!sit;
	.random(X); .wait(X*10000+2000);
   	.print("VOY YO A POR LA MEDICINA");
	!goToMedicina.
	  

	
+!goToMedicina: busy <-
	 .println("Estoy ocupado pero voy a por la medicina igual");
	 .drop_desire(sit);
	 -busy;
	 !aPorMedicina;
	 !aMiBola.

+!goToMedicina: not busy <-
	 .println("No estoy ocupado voy a por la medicina");
	 !aPorMedicina;
	 !aMiBola.

/*+!esperarHoraPerfecta(T) <-
	.println(T);
	if (T<=5){
		.println("Queda poco para hora, voy a esperar...");
		//.drop_desire;
		.wait(T*1000);
		.println("pasado");
		!aMiBola;
	}else{
		.println("Es muy pronto para esperar!");
	}.
*/

+!wakeup : .my_name(Ag) & not busy <-
	+busy;
	!check_bored;
	.println("Owner just woke up and needs to go to the fridge"); 
	.wait(3000);
	-busy;
	!sit.
+!wakeup : .my_name(Ag) & busy <-
	.println("Owner is doing something now, is not asleep");
	.wait(10000);
	!wakeup.
	
+!walk : .my_name(Ag) & not busy <- 
	+busy;  
	.println("Owner is not busy, is sit down on the sofa");
	.wait(500);
	!at(Ag,sofa);
	.wait(2000);
	//.println("Owner is walking at home"); 
	-busy;
	!open.
+!walk : .my_name(Ag) & busy <-
	.println("Owner is doing something now and could not walk");
	.wait(6000);
	!walk.

+!open : .my_name(Ag) & not busy <-
	+busy;   
	.println("Owner goes to the home door");
	.wait(200);
	!at(Ag, delivery);
	.println("Owner is opening the door"); 
	.random(X); .wait(X*7351+2000); // Owner takes a random amount of time to open the door 
	!at(Ag, sofa);
	sit(sofa);
	.wait(5000);
	!at(Ag, fridge);
	.wait(10000);
	!at(Ag, chair3);
	sit(chair3);
	-busy.
+!open : .my_name(Ag) & busy <-
	.println("Owner is doing something now and could not open the door");
	.wait(8000);
	!open.
 
+!sit : .my_name(Ag) & not busy <- 
	+busy; 
	.println("Owner goes to the fridge to get a beer.");
	.wait(1000);
	!at(Ag, fridge);
	.println("Owner is hungry and is at the fridge getting something"); 
	//.println("He llegado al frigorifico");
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
	.println("Owner is doing something now and could not go to fridge");
	.wait(300);
	!sit.

+!at(Ag, P) : at(Ag, P) <- 
	.println("Owner is at ",P);
	.wait(500).
+!at(Ag, P) : not at(Ag, P) <- 
	.println("Going to ", P);
	!go(P);                                        
	.println("Checking if is at ", P);
	!at(Ag, P).            
	                                                   
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomAg) <-                             
	//.println("Al estar en la misma habitación se debe mover directamente a: ", P);
	move_towards(P).  
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & atDoor(Door) <-
	//.println("Al estar en la puerta ", Door, " se dirige a ", P);                        
	move_towards(P); 
	!go(P).       
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  connect(RoomAg, RoomP, Door) & not atDoor(Door) <-
	//.println("Al estar en una habitación contigua se mueve hacia la puerta: ", Door);
	move_towards(Door); 
	!go(P).  
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  not connect(RoomAg, RoomP, _) & connect(RoomAg, Room, DoorR) &
		  connect(Room, RoomP, DoorP) & atDoor(DoorR) <-
	//.println("Se mueve a: ", DoorP, " para ir a la habitación ", RoomP);
	move_towards(DoorP); 
	!go(P).      
+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP &
		  not connect(RoomAg, RoomP, _) & connect(RoomAg, Room, DoorR) &
		  connect(Room, RoomP, DoorP) & not atDoor(DoorR) <-
	//.println("Se mueve a: ", DoorR, " para ir a la habitación contigua, ", Room);
	move_towards(DoorR); 
	!go(P). 

+!go(P) : atRoom(RoomAg) & atRoom(P, RoomP) & not RoomAg == RoomP <-
	//.println("Owner is at ", RoomAg,", that is not a contiguous room to ", RoomP);
	move_towards(P).                                                          
-!go(P) <- .println("Something goes wrong......").
	                                                                        
	
+!get(drug) : .my_name(Name) <- 
   Time = math.ceil(math.random(4000));
   .println("I am waiting ", Time, " ms. before asking the nurse robot for my medicine.");
   .wait(Time);
   .send(enfermera, achieve, has(Name, drug)).

+has(owner,drug) : true <-
   .println("Owner take the drug.");
   !take(drug).
-has(owner,drug) : true <-
   .println("Owner ask for drug. It is time to take it.");
   !get(drug).
                                       
// while I have drug, sip
+!take(drug) : has(owner, drug) <-
   sip(drug);
   .println("Owner is siping the drug.");
   !take(drug).
+!take(drug) : not has(owner, drug) <-
   .println("Owner has finished to take the drug.").//;
   //-asked(drug).

+!check_bored : true
   <- .random(X); .wait(X*5000+2000);  // Owner get bored randomly
      .send(enfermera, askOne, time(_), R); // when bored, owner ask the robot about the time
      .print(R);
	  .send(enfermera, tell, chat("What's the weather in Ourense?"));
      !check_bored.




