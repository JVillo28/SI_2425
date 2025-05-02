//package src.env;
package domotic;
import jason.asSyntax.*;
import jason.environment.Environment;
import jason.environment.grid.Location;
import java.util.logging.Logger;
import java.util.Map.Entry;
import java.util.Set;
import java.util.Iterator;
import java.util.Map;

public class HouseEnv extends Environment { //Al extender Environment, los metodos init y execute, hay que implementarlos, stop casi también

    // common literals
    public static final Literal of   = Literal.parseLiteral("open(fridge)");
    public static final Literal clf  = Literal.parseLiteral("close(fridge)");
	public static final Literal ok   = Literal.parseLiteral("open(kit)");
    public static final Literal clk  = Literal.parseLiteral("close(kit)");
	public static final Literal uc   = Literal.parseLiteral("useCharger");
    public static final Literal qc   = Literal.parseLiteral("quitCharger");

	


    public static final Literal af   = Literal.parseLiteral("at(enfermera,fridge)");
    public static final Literal ao   = Literal.parseLiteral("at(enfermera,owner)");
    public static final Literal ad   = Literal.parseLiteral("at(enfermera,delivery)");
	public static final Literal ac   = Literal.parseLiteral("at(enfermera, charger)");
	public static final Literal ak   = Literal.parseLiteral("at(enfermera, kit)");
	public static final Literal oar  = Literal.parseLiteral("at(enfermera, afterChargerRobot)");
	public static final Literal wec  = Literal.parseLiteral("at(enfermera, waitCharger)");
	


	public static final Literal aaf   = Literal.parseLiteral("at(auxiliar,fridge)");
    public static final Literal aao   = Literal.parseLiteral("at(auxiliar,owner)");
    public static final Literal aad   = Literal.parseLiteral("at(auxiliar,delivery)");
	public static final Literal ai   =  Literal.parseLiteral("at(auxiliar,initial)");
    public static final Literal aac   = Literal.parseLiteral("at(auxiliar, charger)");
	public static final Literal aak   = Literal.parseLiteral("at(auxiliar, kit)");
	public static final Literal aca  = Literal.parseLiteral("at(auxiliar, afterChargerAuxiliar)");
	public static final Literal wac  = Literal.parseLiteral("at(auxiliar, waitCharger)");
	
    public static final Literal oaf  = Literal.parseLiteral("at(owner,fridge)");
    public static final Literal oac1 = Literal.parseLiteral("at(owner,chair1)");
    public static final Literal oac2 = Literal.parseLiteral("at(owner,chair2)");
    public static final Literal oac3 = Literal.parseLiteral("at(owner,chair3)");
    public static final Literal oac4 = Literal.parseLiteral("at(owner,chair4)");
    public static final Literal oasf = Literal.parseLiteral("at(owner,sofa)");
	public static final Literal oak	 = Literal.parseLiteral("at(owner,kit)");


	//Literales nuevos
	public static final Literal getMed = Literal.parseLiteral("getMedicina(X)");
	public static final Literal hm     = Literal.parseLiteral("en_mano(X)");


    static Logger logger = Logger.getLogger(HouseEnv.class.getName());

    HouseModel model; // the model of the grid

    @Override
    public void init(String[] args) {
        model = new HouseModel();

        if (args.length > 0 && args[0].equals("gui")) {
            HouseView view  = new HouseView(model);
            model.setView(view);
        }

        updatePercepts();
    }
	
    void updateAgentsPlace() {
		// get the robot location
        Location lRobot = model.getAgPos(model.NURSE);
		// get the robot room location
		String RobotPlace = model.getRoom(lRobot);
		addPercept("enfermera", Literal.parseLiteral("atRoom("+RobotPlace+")"));
        addPercept("owner", Literal.parseLiteral("atRoom(robot,"+RobotPlace+")"));
		addPercept("auxiliar", Literal.parseLiteral("atRoom(robot,"+RobotPlace+")"));

		// get the owner location
        Location lOwner = model.getAgPos(model.OWNER);
		// get the owner room location
		String OwnerPlace = model.getRoom(lOwner);
		addPercept("owner", Literal.parseLiteral("atRoom("+OwnerPlace+")"));  
        addPercept("enfermera", Literal.parseLiteral("atRoom(owner,"+OwnerPlace+")"));
		addPercept("auxiliar", Literal.parseLiteral("atRoom(owner,"+RobotPlace+")"));


		Location lAuxiliar = model.getAgPos(model.AUXILIAR);
		String AuxiliarPlace = model.getRoom(lAuxiliar);

		addPercept("auxiliar", Literal.parseLiteral("atRoom("+AuxiliarPlace+")"));
		addPercept("enfermera", Literal.parseLiteral("atRoom(auxiliar,"+AuxiliarPlace+")"));
		addPercept("owner", Literal.parseLiteral("atRoom(auxiliar,"+AuxiliarPlace+")"));
		
		String doorName = null;
		

		if (lRobot.distance(model.lDoorKit1) == 0) doorName = "doorKit1";
		else if (lRobot.distance(model.lDoorKit2) == 0) doorName = "doorKit2";
		else if (lRobot.distance(model.lDoorSal1) == 0) doorName = "doorSal1";
		else if (lRobot.distance(model.lDoorSal2) == 0) doorName = "doorSal2";
		else if (lRobot.distance(model.lDoorBath1) == 0) doorName = "doorBath1";
		else if (lRobot.distance(model.lDoorBath2) == 0) doorName = "doorBath2";
		else if (lRobot.distance(model.lDoorBed1) == 0) doorName = "doorBed1";
		else if (lRobot.distance(model.lDoorBed2) == 0) doorName = "doorBed2";
		else if (lRobot.distance(model.lDoorBed3) == 0) doorName = "doorBed3";

		if (doorName != null) {
			addPercept("enfermera", Literal.parseLiteral("atDoor("+ doorName +")"));
		}

		doorName = null;
		
		if (lOwner.distance(model.lDoorKit1) == 0) doorName = "doorKit1";
		else if (lOwner.distance(model.lDoorKit2) == 0) doorName = "doorKit2";
		else if (lOwner.distance(model.lDoorSal1) == 0) doorName = "doorSal1";
		else if (lOwner.distance(model.lDoorSal2) == 0) doorName = "doorSal2";
		else if (lOwner.distance(model.lDoorBath1) == 0) doorName = "doorBath1";
		else if (lOwner.distance(model.lDoorBath2) == 0) doorName = "doorBath2";
		else if (lOwner.distance(model.lDoorBed1) == 0) doorName = "doorBed1";
		else if (lOwner.distance(model.lDoorBed2) == 0) doorName = "doorBed2";
		else if (lOwner.distance(model.lDoorBed3) == 0) doorName = "doorBed3";
		


		if (doorName != null) {
			addPercept("owner", Literal.parseLiteral("atDoor("+ doorName +")"));
		} 		

		doorName = null;
		
		if (lAuxiliar.distance(model.lDoorKit1) == 0) doorName = "doorKit1";
		else if (lAuxiliar.distance(model.lDoorKit2) == 0) doorName = "doorKit2";
		else if (lAuxiliar.distance(model.lDoorSal1) == 0) doorName = "doorSal1";
		else if (lAuxiliar.distance(model.lDoorSal2) == 0) doorName = "doorSal2";
		else if (lAuxiliar.distance(model.lDoorBath1) == 0) doorName = "doorBath1";
		else if (lAuxiliar.distance(model.lDoorBath2) == 0) doorName = "doorBath2";
		else if (lAuxiliar.distance(model.lDoorBed1) == 0) doorName = "doorBed1";
		else if (lAuxiliar.distance(model.lDoorBed2) == 0) doorName = "doorBed2";
		else if (lAuxiliar.distance(model.lDoorBed3) == 0) doorName = "doorBed3";
		


		if (doorName != null) {
			addPercept("auxiliar", Literal.parseLiteral("atDoor("+ doorName +")"));
		} 
 		
		
	}
      
    void updateThingsPlace() {
		// get the fridge location
		String fridgePlace = model.getRoom(model.lFridge);
		addPercept(Literal.parseLiteral("atRoom(fridge, "+fridgePlace+")"));
		String sofaPlace = model.getRoom(model.lSofa);
		addPercept(Literal.parseLiteral("atRoom(sofa, "+sofaPlace+")")); 
		String chair1Place = model.getRoom(model.lChair1);
		addPercept(Literal.parseLiteral("atRoom(chair1, "+chair1Place+")"));
		String chair2Place = model.getRoom(model.lChair2);
		addPercept(Literal.parseLiteral("atRoom(chair2, "+chair2Place+")"));
		String chair3Place = model.getRoom(model.lChair3);
		addPercept(Literal.parseLiteral("atRoom(chair3, "+chair3Place+")"));
		String chair4Place = model.getRoom(model.lChair4);
		addPercept(Literal.parseLiteral("atRoom(chair4, "+chair4Place+")"));
		String deliveryPlace = model.getRoom(model.lDeliver);
		addPercept(Literal.parseLiteral("atRoom(delivery, "+deliveryPlace+")"));
		String chargerPlace = model.getRoom(model.lCharger);
		addPercept(Literal.parseLiteral("atRoom(charger, "+chargerPlace+")"));
		String initialPlace = model.getRoom(model.lInitial);
		addPercept(Literal.parseLiteral("atRoom(initial, "+initialPlace+")"));
		String bed1Place = model.getRoom(model.lBed1);
		addPercept(Literal.parseLiteral("atRoom(bed1, "+bed1Place+")"));
		String bed2Place = model.getRoom(model.lBed2);
		addPercept(Literal.parseLiteral("atRoom(bed2, "+bed2Place+")"));
		String bed3Place = model.getRoom(model.lBed3);
		addPercept(Literal.parseLiteral("atRoom(bed3, "+bed3Place+")"));
		String kitPlace = model.getRoom(model.lKit);
		addPercept(Literal.parseLiteral("atRoom(kit, "+kitPlace+")"));
		String afterChargerPlaceRobot = model.getRoom(model.lAfterChargerRobot);
		addPercept(Literal.parseLiteral("atRoom(afterChargerRobot, "+afterChargerPlaceRobot+")"));
		String afterChargerPlaceAuxiliar = model.getRoom(model.lAfterChargerAuxiliar);
		addPercept(Literal.parseLiteral("atRoom(afterChargerAuxiliar, "+afterChargerPlaceAuxiliar+")"));
		String waitChargerPlace = model.getRoom(model.lWaitCharger);
		addPercept(Literal.parseLiteral("atRoom(waitCharger, "+waitChargerPlace+")"));
	}
	                                                       
    /** creates the agents percepts based on the HouseModel */
    void updatePercepts() {
        // clear the percepts of the agents
        clearPercepts("enfermera");
		clearPercepts("auxiliar");
        clearPercepts("owner");
		
		updateAgentsPlace();
		updateThingsPlace(); 
		
		Location lRobot = model.getAgPos(model.NURSE);
		Location lAuxiliar = model.getAgPos(model.AUXILIAR);
		Location lOwner = model.getAgPos(model.OWNER);
		
		if(model.kitOpen){
			addPercept("owner",ok);
			addPercept("enfermera",ok);
			addPercept("auxiliar",ok);
		}
		else{
			addPercept("owner",clk);
			addPercept("enfermera",clk);
			addPercept("auxiliar",clk);
		}
		


        if (lRobot.distance(model.lFridge)==1) {
            addPercept("enfermera", af);
        }
		
		if (lAuxiliar.distance(model.lFridge)==1) {
            addPercept("auxiliar", aaf);
        }
		
		if (lAuxiliar.distance(model.lAfterChargerAuxiliar)==0) {
			addPercept("auxiliar", aca);
		}

		if (lRobot.distance(model.lAfterChargerRobot)==0) {
			addPercept("enfermera", oar);
		}

		if (lAuxiliar.distance(model.lWaitCharger)==0) {
			addPercept("auxiliar", wac);
		}

		if (lRobot.distance(model.lWaitCharger)==0) {
			addPercept("enfermera", wec);
		}


        if (lOwner.distance(model.lFridge)==1) {
            addPercept("owner", oaf);
        }
		
		if (lRobot.distance(model.lKit)==1) {
            addPercept("enfermera", ak);
        }
		
		if (lAuxiliar.distance(model.lKit)==1) {
            addPercept("auxiliar", aak);
        }
		
        if (lOwner.distance(model.lKit)==1) {
            addPercept("owner", oak);
        } 
		
        if (lRobot.distance(lOwner)==1) {                                                     
            addPercept("enfermera", ao);
        }

		if (lAuxiliar.distance(lOwner)==1) {                                                     
            addPercept("auxiliar", aao);
        }

        if (lRobot.distance(model.lDeliver)==1) {
            addPercept("enfermera", ad);
        }

		if (lAuxiliar.distance(model.lDeliver)==1) {
            addPercept("auxiliar", aad);
        }

		if(lRobot.distance(model.lCharger)==0){
			addPercept("enfermera", ac);
		}

		if(lAuxiliar.distance(model.lCharger)==0) {
			addPercept("auxiliar", aac);
		}

		if (lAuxiliar.distance(model.lInitial)==1) {
            addPercept("auxiliar", ai);
        }

        if (lOwner.distance(model.lChair1)==0) {
            addPercept("owner", oac1);
			System.out.println("[owner] is at Chair1.");
        }

        if (lOwner.distance(model.lChair2)==0) {
            addPercept("owner", oac2);
			System.out.println("[owner] is at Chair2.");
        }

        if (lOwner.distance(model.lChair3)==0) {
            addPercept("owner", oac3);
			System.out.println("[owner] is at Chair3.");
        }

        if (lOwner.distance(model.lChair4)==0) {                            
            addPercept("owner", oac4);
			System.out.println("[owner] is at Chair4.");
        }
                                                                               
        if (lOwner.distance(model.lSofa)==0) {
            addPercept("owner", oasf);
			System.out.println("[owner] is at Sofa.");
        }

		
    }


    @Override
    public boolean executeAction(String ag, Structure action) { 
        
		System.out.println("["+ag+"] doing: "+action); 

		boolean result = false;
        if (action.getFunctor().equals("sit")) {
            String l = action.getTerm(0).toString();
            Location dest = null;
			switch (l) {
				case "chair1": dest = model.lChair1; 
				break;
				case "chair2": dest = model.lChair2;  
				break;     
				case "chair3": dest = model.lChair3; 
				break;
				case "chair4": dest = model.lChair4; 
				break;
				case "sofa": dest = model.lSofa; 
				break;
			};
			try {
				if (ag.equals("owner")) {
					System.out.println("[owner] is sitting");
					result = model.sit(model.OWNER,dest);
				} 
			} catch (Exception e) {
               e.printStackTrace();
			}
		} else if (action.equals(of)) { // of = open(fridge)
            result = model.openFridge();

        } else if (action.equals(clf)) { // clf = close(fridge)
            result = model.closeFridge();   

        } else if (action.equals(ok)) { // ok = open(kit)
            result = model.openKit();

        } else if (action.equals(clk)) { // clk = close(kit)
            result = model.closeKit(); 
			   
		} else if (action.equals(uc)) { // uc = use(charger)
            result = model.useCharger();

        } else if (action.equals(qc)) { // qc = quit(charger)
            result = model.quitCharger();    
                                                    
        } else if (action.getFunctor().equals("move_towards")) {
            String l = action.getTerm(0).toString();
            Location dest = null;
			switch (l) {
				case "fridge": dest = model.lFridge; 
				break;
				case "owner": dest = model.getAgPos(HouseModel.OWNER);  
				break;     
				case "delivery": dest = model.lDeliver; 
				break;
				case "afterChargerRobot": dest = model.lAfterChargerRobot;
				break;
				case "afterChargerAuxiliar": dest = model.lAfterChargerAuxiliar;
				break;
				case "waitCharger": dest = model.lWaitCharger;
				break;
				case "charger": dest = model.lCharger;
				break;
				case "initial": dest = model.lInitial;  
				break;     
				case "chair1": dest = model.lChair1; 
				break;
				case "chair2": dest = model.lChair2; 
				break;
				case "chair3": dest = model.lChair3; 
				break;
				case "chair4": dest = model.lChair4; 
				break;
				case "sofa": dest = model.lSofa; 
				break;
				case "washer": dest = model.lWasher; 
				break;
				case "table": dest = model.lTable; 
				break;
				case "doorKit1": dest = model.lDoorKit1; 
				break;            
				case "doorKit2": dest = model.lDoorKit2; 
				break;
				case "doorSal1": dest = model.lDoorSal1; 
				break;
				case "doorSal2": dest = model.lDoorSal2; 
				break;
				case "doorBath1": dest = model.lDoorBath1; 
				break;
				case "doorBath2": dest = model.lDoorBath2; 
				break;
				case "doorBed1": dest = model.lDoorBed1; 
				break;
				case "doorBed2": dest = model.lDoorBed2; 
				break;
				case "doorBed3": dest = model.lDoorBed3;                  
				break;
				case "kit": dest 	= model.lKit;                  
				break;
 
 
            }
            try {
                if (ag.equals("enfermera")) {
					result = model.moveTowards(HouseModel.NURSE, dest);
				}else if (ag.equals("auxiliar")) {
					result = model.moveTowards(HouseModel.AUXILIAR, dest);
				}
				else {
					result = model.moveTowards(HouseModel.OWNER, dest);
				}
            } catch (Exception e) {
                e.printStackTrace();
            }    
		
		} else if (action.getFunctor().equals("getMedicina")) {
            Term xTerm = action.getTerm(0);
			String medicina = ((Atom) xTerm).getFunctor();
			result = model.getMedicina(medicina,1);
		} else if (action.getFunctor().equals("reponerStock")) {
            Term xTerm = action.getTerm(0);
			String medicina = ((Atom) xTerm).getFunctor();
			result = model.reponerStock(medicina);
		} else if (action.getFunctor().equals("reponerMedCaducidad")) {
            Term xTerm = action.getTerm(0);
			String medicina = ((Atom) xTerm).getFunctor();
			result = model.reponerMedCaducidad(medicina);
		}else if (action.getFunctor().equals("mano_en")) {
            result = model.handInMedicina();
		} else if (action.getFunctor().equals("getStock")) {
			Set<Entry<String,Integer>> med = model.disponibilidadMedicamentos.entrySet();	
			Iterator<Entry<String, Integer>> it = med.iterator();
			while(it.hasNext()){
				Entry<String, Integer> aux = it.next();
				Literal precept = Literal.parseLiteral("stock("+aux.getKey()+","+aux.getValue()+")");		
				addPercept(ag, precept);
			}
			return true;
		} else {
            logger.info("Failed to execute action "+action);
        }

        if (result) {
            updatePercepts();
            try {
                Thread.sleep(200);
            } catch (Exception e) {}
        }
        return result;
	}
}
