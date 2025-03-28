//package src.env;

import jason.asSyntax.*;
import jason.environment.Environment;
import jason.environment.grid.Location;
import java.util.logging.Logger;

public class HouseEnv extends Environment { //Al extender Environment, los metodos init y execute, hay que implementarlos, stop casi también

    // common literals
    public static final Literal of   = Literal.parseLiteral("open(fridge)");
    public static final Literal clf  = Literal.parseLiteral("close(fridge)");
    public static final Literal gb   = Literal.parseLiteral("get(beer)");
    public static final Literal hb   = Literal.parseLiteral("hand_in(beer)");
    public static final Literal sb   = Literal.parseLiteral("sip(beer)");
    public static final Literal hob  = Literal.parseLiteral("has(owner,beer)");

    public static final Literal af   = Literal.parseLiteral("at(robot,fridge)");
    public static final Literal ao   = Literal.parseLiteral("at(robot,owner)");
    public static final Literal ad   = Literal.parseLiteral("at(robot,delivery)");
	public static final Literal ak   = Literal.parseLiteral("at(robot,kit)");
	
    public static final Literal oaf  = Literal.parseLiteral("at(owner,fridge)");
    public static final Literal oac1 = Literal.parseLiteral("at(owner,chair1)");
    public static final Literal oac2 = Literal.parseLiteral("at(owner,chair2)");
    public static final Literal oac3 = Literal.parseLiteral("at(owner,chair3)");
    public static final Literal oac4 = Literal.parseLiteral("at(owner,chair4)");
    public static final Literal oasf = Literal.parseLiteral("at(owner,sofa)");
    public static final Literal oad  = Literal.parseLiteral("at(owner,delivery)");
	public static final Literal oak  = Literal.parseLiteral("at(owner,kit)");

	public static final Literal gmp  = Literal.parseLiteral("getMedicina(paracetamol)");
	public static final Literal ok  = Literal.parseLiteral("abrir(kit)");
	public static final Literal ck  = Literal.parseLiteral("cerrar(kit)");

    static Logger logger = Logger.getLogger(HouseEnv.class.getName());

    HouseModel model; // the model of the grid

    @Override
    public void init(String[] args) {
        model = new HouseModel();

        if (args.length == 1 && args[0].equals("gui")) {
            HouseView view  = new HouseView(model);
            model.setView(view);
        }

        updatePercepts();
    }
	
    void updateAgentsPlace() {
		// get the robot location
        Location lRobot = model.getAgPos(1);
		// get the robot room location
		String RobotPlace = model.getRoom(lRobot);
		addPercept("robot", Literal.parseLiteral("atRoom("+RobotPlace+")"));
        addPercept("owner", Literal.parseLiteral("atRoom(robot,"+RobotPlace+")"));
		// get the owner location
        Location lOwner = model.getAgPos(0);
		// get the owner room location
		String OwnerPlace = model.getRoom(lOwner);
		addPercept("owner", Literal.parseLiteral("atRoom("+OwnerPlace+")"));  
        addPercept("robot", Literal.parseLiteral("atRoom(owner,"+OwnerPlace+")"));
		
		String doorName = null;
		if (lRobot.distance(model.lDoorHome) == 0) doorName = "lDoorHome";
		else if (lRobot.distance(model.lDoorKit1) == 0) doorName = "doorKit1";
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
		if (lOwner.distance(model.lDoorHome) == 0) doorName = "lDoorHome";
		else if (lOwner.distance(model.lDoorKit1) == 0) doorName = "doorKit1";
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
 		
		
	}
      
    void updateThingsPlace() {
		// get the fridge location
		String KitPlace = model.getRoom(model.lKit);
		addPercept(Literal.parseLiteral("atRoom(kit, "+KitPlace+")"));
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
		String bed1Place = model.getRoom(model.lBed1);
		addPercept(Literal.parseLiteral("atRoom(bed1, "+bed1Place+")"));
		String bed2Place = model.getRoom(model.lBed2);
		addPercept(Literal.parseLiteral("atRoom(bed2, "+bed2Place+")"));
		String bed3Place = model.getRoom(model.lBed3);
		addPercept(Literal.parseLiteral("atRoom(bed3, "+bed3Place+")"));
	}
	                                                       
    /** creates the agents percepts based on the HouseModel */
    void updatePercepts() {
        // clear the percepts of the agents
        clearPercepts("robot");
        clearPercepts("owner");
		
		updateAgentsPlace();
		updateThingsPlace(); 
		
		Location lRobot = model.getAgPos(0);
		Location lOwner = model.getAgPos(1);
		
		if (lRobot.distance(model.lKit)<2) {
            addPercept("robot", ak);
        } 

        if (lRobot.distance(model.lFridge)<2) {
            addPercept("robot", af);
        } 
		
        if (lOwner.distance(model.lFridge)<2) {
            addPercept("owner", oaf);
        } 
		
        if (lRobot.distance(lOwner)==1) {                                                     
            addPercept("robot", ao);
        }

        if (lRobot.distance(model.lDeliver)==1) {
            addPercept("robot", ad);
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

        if (lOwner.distance(model.lDeliver)==0) {
            addPercept("owner", oad);
        }
		if (lOwner.distance(model.lKit)==1) {
            addPercept("owner", oak);
        }

        // add beer "status" the percepts
        if (model.fridgeOpen) {
            addPercept("robot", Literal.parseLiteral("stock(beer,"+model.availableBeers+")"));
        }
        if (model.sipCount > 0) {
            addPercept("robot", hob);
            addPercept("owner", hob);
        }
    }


    @Override
    public boolean executeAction(String ag, Structure action) { 
        
		System.out.println("["+ag+"] doing: "+action); 
		//java.util.List<Literal> perceptsOwner = consultPercepts("owner");
		//java.util.List<Literal> perceptsRobot = consultPercepts("enfermera");  
		//System.out.println("[owner] has the following percepts: "+perceptsOwner);
		//System.out.println("[enfermera] has the following percepts: "+perceptsRobot);
        
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
				if (ag.equals("robot")) {
					System.out.println("[robot] is sitting");
					result = model.sit(0,dest);
				} else {
					System.out.println("[owner] is sitting");
					result = model.sit(1,dest);
				}
			} catch (Exception e) {
               e.printStackTrace();
			}
		} else if (action.equals(of)) { // of = open(fridge)
            result = model.openFridge();

        } else if (action.equals(clf)) { // clf = close(fridge)
            result = model.closeFridge();     
        } else if (action.equals(ok)) { // of = open(fridge)
            result = model.abrirKit();

        } else if (action.equals(ck)) { // clf = close(fridge)
            result = model.cerrarKit();
                                                                     
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
				case "doorBed_P": dest = model.lDoorBed_P; 
				break;            
				case "doorBed_I1": dest = model.lDoorBed_I1; 
				break;
				case "doorBed_I2": dest = model.lDoorBed_I2; 
				break;
				case "doorKit_Hall": dest = model.lDoorKit_Hall; 
				break;
				case "doorKit_Corr": dest = model.lDoorKit_HW; 
				break;
				case "doorLivi_Hall": dest = model.lDoorLivi_Hall; 
				break;
				case "doorLivi_Corr": dest = model.lDoorLivi_HW; 
				break;
				case "doorBath_Bed1": dest = model.lDoorBath_BedP; 
				break;
				case "doorBath_Corr": dest = model.lDoorBath_HW;                  
				break;
				case "kit": dest = model.lKit;                  
				break; 
            }
            try {
                if (ag.equals("robot")) {
					result = model.moveTowards(HouseModel.NURSE, dest);
				} else {
					result = model.moveTowards(HouseModel.OWNER, dest);
				}
            } catch (Exception e) {
                e.printStackTrace();
            }    
		
		} else if (action.equals(gmp)){
			result = model.getMedicina(model.PARACETAMOL);
        } else if (action.equals(gb)) {
            result = model.getBeer();

        } else if (action.equals(hb)) {
            result = model.handInBeer();

        } else if (action.equals(sb)) {
            result = model.sipBeer();

        } else if (action.getFunctor().equals("deliver")) {
            // wait 4 seconds to finish "deliver"
            try {
                result = model.addBeer( (int)((NumberTerm)action.getTerm(1)).solve());
                Thread.sleep(4000);
            } catch (Exception e) {
                logger.info("Failed to execute action deliver!"+e);
            }

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
