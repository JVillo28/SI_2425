/* Initial goals */
pauta(paracetamol, 8). //paracetamol
pauta(ibuprofeno, 8). //ibuprofeno
pauta(dalsy, 4). // dalsy
pauta(frenadol, 6). //frenadol
pauta(aspirina, 8). //aspirina

!send_pauta.
!get(beer).   // initial goal: get a beer
!check_bored. // initial goal: verify whether I am getting bored


+!send_pauta : true  <-
.findall(pauta(X,Y), pauta(X,Y), L);
.print("Mi pauta: ", L);
.send(robot, tell, L).



+!get(beer) : true
   <- .send(robot, achieve, bring(owner,beer)).

+has(owner,beer) : true
   <- !drink(beer).
-has(owner,beer) : true
   <- !get(beer).

// if I have not beer finish, in other case while I have beer, sip
+!drink(beer) : not has(owner,beer)
   <- true.
+!drink(beer) //: has(owner,beer)
   <- sip(beer);
     !drink(beer).

+!check_bored : true
   <- .random(X); .wait(X*5000+2000);   // i get bored at random times
      .send(robot, askOne, time(_), R); // when bored, I ask the robot about the time
      .print(R);
      !check_bored.

+msg(M)[source(Ag)] : true
   <- .print("Message from ",Ag,": ",M);
      -msg(M).



+!go_at(owner,P) : not at(owner,P)
  <- move_towards(P);
     !go_at(owner,P).
     
+!go_at(owner,P) : at(owner,P) <- true.