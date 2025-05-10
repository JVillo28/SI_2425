package domotic;
import jason.environment.grid.GridWorldModel;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import jason.environment.grid.Area;
import jason.environment.grid.Location;

/** class that implements the Model of Domestic Robot application */
public class HouseModel extends GridWorldModel {

    // constants for the agents
	public static final int NURSE  			=    0;
    public static final int OWNER  			=    1;
	public static final int AUXILIAR  		=    2;
	
	// constants for the grid objects

    public static final int COLUMN  =    4;
    public static final int CHAIR  	=    8;
    public static final int SOFA  	=   16;
    public static final int FRIDGE 	=   32;
    public static final int WASHER 	=   64;
	public static final int DOOR 	=  128;                                       
	public static final int CHARGER =  256;
    public static final int TABLE  	=  512;
    public static final int BED	   	= 1024;
	public static final int KIT		= 2048; 

	private Map<Integer, Set<Location>> localizacionesVisitadas;
	//almacena las localizaciones que recorre un agente

    // the grid size                                                     
    public static final int GSize = 12;     //Cells
	public final int GridSize = 1080;    	//Width

	public int bateria_robot = GSize*2*GSize;
	public int bateria_auxiliar = GSize*2*GSize;
                          
    boolean fridgeOpen  = false; 	// whether the fridge is open
	boolean kitOpen		= false;                              

	public final String PARACETAMOL = "paracetamol";
	public final String IBUPROFENO 	= "ibuprofeno";
	public final String DALSY 		= "dalsy";
	public final String FRENADOL 	= "frenadol";
	public final String ASPIRINA 	= "aspirina";

	public Map<String,Integer> disponibilidadMedicamentos = new HashMap<>();
	boolean chargerFree 		= true;	


    
	// Initialization of the objects Location on the domotic home scene 
    Location lSofa	 	= new Location(GSize/2, GSize-2);
    Location lChair1  	= new Location(GSize/2+2, GSize-3);
    Location lChair3 	= new Location(GSize/2-1, GSize-3);
    Location lChair2 	= new Location(GSize/2+1, GSize-4); 
    Location lChair4 	= new Location(GSize/2, GSize-4); 
    Location lDeliver 	= new Location(0, GSize-1);
	Location lCharger	= new Location(2, GSize-5);
	Location lInitial 	= new Location(0, 0);
    Location lWasher 	= new Location(GSize/3, 0);	
    Location lFridge 	= new Location(2, 0);
	Location lKit		= new Location(0, 0);


    Location lTable  	= new Location(GSize/2, GSize-3);
	Location lBed2		= new Location(GSize+2, 0);
	Location lBed3		= new Location(GSize*2-3,0);
	Location lBed1		= new Location(GSize+1, GSize*3/4);

	//Creating areas for furnitures to make the robot unable to walk towards certain furniture
	Area aSofa	 	= new Area(GSize/2, GSize-2, GSize/2+1, GSize-2);
	Area aTable  	= new Area(GSize/2, GSize-3, GSize/2+1, GSize-3);
	Area aBed2		= new Area(GSize+2, 0, GSize+2+1, 0+1);
	Area aBed3		= new Area(GSize*2-3,0, GSize*2-3+1,0+1);
	Area aBed1		= new Area(GSize+1, GSize*3/4, GSize+1+1, GSize*3/4+1);


	// Initialization of the doors location on the domotic home scene 
	Location lDoorHome 	= new Location(0, GSize-1);  
	Location lDoorKit1	= new Location(0, GSize/2);
	Location lDoorKit2	= new Location(GSize/2+1, GSize/2-1); 
	Location lDoorSal1	= new Location(GSize/4, GSize-1);  
	Location lDoorSal2	= new Location(GSize+1, GSize/2);
	Location lDoorBed1	= new Location(GSize-1, GSize/2);
	Location lDoorBath1	= new Location(GSize-1, GSize/4+1);
	Location lDoorBed3	= new Location(GSize*2-1, GSize/4+1); 	
	Location lDoorBed2	= new Location(GSize+1, GSize/4+1); 	
	Location lDoorBath2	= new Location(GSize*2-4, GSize/2+1);
	Location lAfterChargerRobot = new Location (2, GSize-7);
	Location lAfterChargerAuxiliar = new Location (2, GSize-4);
	Location lWaitCharger = new Location(1, GSize-5);
	
		
	// Initialization of the area modeling the home rooms      
	Area kitchen 	= new Area(0, 0, GSize/2+1, GSize/2-1);
	Area livingroom	= new Area(GSize/3, GSize/2+1, GSize, GSize-1);
	Area bathHW	 	= new Area(GSize/2+2, 0, GSize-1, GSize/3);
	Area bathBedP	= new Area(GSize*2-3, GSize/2+1, GSize*2-1, GSize-1);
	Area bedP		= new Area(GSize+1, GSize/2+1, GSize*2-4, GSize-1);
	Area bedI1		= new Area(GSize, 0, GSize*3/4-1, GSize/3);
	Area bedI2		= new Area(GSize*3/4, 0, GSize*2-1, GSize/3);
	Area hall		= new Area(0, GSize/2+1, GSize/4, GSize-1);
	Area hallway	= new Area(GSize/2+2, GSize/2-1, GSize*2-1, GSize/2);
	
    public HouseModel() {
        super(2*GSize, GSize, 4);
                                                                           
        // Initial location for the owner and the nurse
        setAgPos(NURSE, 2, GSize-7);
		setAgPos(AUXILIAR, 0, 3);  
		setAgPos(OWNER, 23, 8);

		// Location of the furniture of the house
        add(FRIDGE, lFridge); 
		add(WASHER, lWasher); 
		add(DOOR,   lDeliver); 
		add(CHARGER, lCharger);
		add(SOFA,   lSofa);
		add(CHAIR,  lChair2);
		add(CHAIR,  lChair3);
		add(CHAIR,  lChair4);
        add(CHAIR,  lChair1);  
        add(TABLE,  lTable);  
		add(BED,	lBed1);
		add(BED,	lBed2);
		add(BED,	lBed3);
		add(KIT, 	lKit);

		// Locations of doors
		add(DOOR, lDoorKit1);
		add(DOOR, lDoorKit2);
		add(DOOR, lDoorSal1);
		add(DOOR, lDoorSal2);
		add(DOOR, lDoorBath1);
		add(DOOR, lDoorBath2);
		add(DOOR, lDoorBed1);
		add(DOOR, lDoorBed2);
		add(DOOR, lDoorBed3);
		


		addWall(GSize/2+1, 0, GSize/2+1, GSize/2-2);  	
		addWall(GSize/2+1, GSize/4+1, GSize-2, GSize/4+1);   
		addWall(GSize+2, GSize/4+1, GSize*2-2, GSize/4+1);   
		addWall(GSize*2-6, 0, GSize*2-6, GSize/4);
		addWall(GSize, 0, GSize, GSize/4+1);  
		addWall(1, GSize/2, GSize-1, GSize/2);           
		addWall(GSize/4, GSize/2+1, GSize/4, GSize-2);            
		addWall(GSize, GSize/2, GSize, GSize-1);  
		addWall(GSize*2-4, GSize/2+2, GSize*2-4, GSize-1);  
		addWall(GSize+2, GSize/2, GSize*2-1, GSize/2);   

		
		localizacionesVisitadas = new HashMap<>();

		disponibilidadMedicamentos.put(PARACETAMOL,	20);
		disponibilidadMedicamentos.put(IBUPROFENO,	20);
		disponibilidadMedicamentos.put(ASPIRINA,	20);
		disponibilidadMedicamentos.put(DALSY,		20);
		disponibilidadMedicamentos.put(FRENADOL,	20);
 		
		 
     }
	
	 
	 String getRoom (Location thing){  
		
		String byDefault = "kitchen";

		if (bathHW.contains(thing)){
			byDefault = "bath1";
		};
		if (bathBedP.contains(thing)){
			byDefault = "bath2";
		};
		if (bedP.contains(thing)){
			byDefault = "bedroom1";
		};
		if (bedI1.contains(thing)){
			byDefault = "bedroom2";
		};
		if (bedI2.contains(thing)){
			byDefault = "bedroom3";
		};
		if (hallway.contains(thing)){
			byDefault = "hallway";
		};
		if (livingroom.contains(thing)){
			byDefault = "livingroom";
		};
		if (hall.contains(thing)){
			byDefault = "hall";
		};
		return byDefault;
	}

	boolean sit(int Ag, Location dest) { 
		Location loc = getAgPos(Ag);
		if (loc.isNeigbour(dest)) {
			setAgPos(Ag, dest);
		};
		return true;
	}

	boolean openFridge() {
        boolean toRet=false;
		if (!fridgeOpen) {
            fridgeOpen = true;
            toRet = true;
        } else {
            toRet = false;
        }
		return toRet;
    }

    boolean closeFridge() {
		boolean toRet=false;
        if (fridgeOpen) {
            fridgeOpen = false;
            toRet = true;
        } else {
            toRet =  false;
        }
		return toRet;
    }

	boolean openKit() {
        boolean toRet=false;
		if (!kitOpen) {
			mostrarMedicinas();
            kitOpen = true;
            toRet = true;
        } else {
            toRet = false;
        }
		return toRet;
    }

    boolean closeKit() {
		boolean toRet=false;
        if (kitOpen) {
            kitOpen = false;
            toRet = true;
        } else {
            toRet =  false;
        }
		return toRet;
    }   

	boolean useCharger() {
		boolean toRet = false;
		if (chargerFree){
			chargerFree = false;
			toRet = true;
		} else {
			toRet =  false;
		}
		return toRet;
	}

	boolean quitCharger() {
		boolean toRet = false;
		if (!chargerFree){
			chargerFree = true;
			toRet = true;
		} else {
			toRet =  false;
		}
		return toRet;
	}
	
	boolean getMedicina(String medicina, int unidad){
		boolean toRet = false;
		if(disponibilidadMedicamentos.containsKey(medicina) && kitOpen && disponibilidadMedicamentos.get(medicina)>0 ){
			disponibilidadMedicamentos.put(medicina,disponibilidadMedicamentos.get(medicina)-1);
			System.out.println("Eliminado "+Integer.toString(unidad)+" unidad de " + medicina);
			toRet = true;
		} else{
			System.out.println("No hay más " + medicina);
			toRet = false;
		} 
		return toRet;
	}

	boolean mostrarMedicinas(){
		System.out.println("Las medicinas disponibles son:");
		System.out.println(disponibilidadMedicamentos.toString());
		return true;
	}

	
	boolean reponerStock(String medicina){
		boolean toRet=false;
		if(disponibilidadMedicamentos.containsKey(medicina)){
			disponibilidadMedicamentos.put(medicina,disponibilidadMedicamentos.get(medicina)+10);
			toRet = true;
		} else{
			toRet = false;
		} 
		return toRet;
	}

	boolean reponerMedCaducidad(String medicina){
		boolean toRet=false;
		if(disponibilidadMedicamentos.containsKey(medicina)){
			disponibilidadMedicamentos.put(medicina,20);
			toRet = true;
		} else{
			toRet = false;
		} 
		return toRet;
	}

	


	// Now we must see if any furniture area is containing the positions x and y.  
	boolean canMoveTo (int Ag, int x, int y) {
		boolean toRet = false;
		Location siguiente = new Location(x,y);
		if (Ag == NURSE || Ag == AUXILIAR) {
			toRet = (isFree(x,y) && !hasObject(WASHER,x,y) && !aTable.contains(siguiente) &&
		           !aSofa.contains(siguiente) && !hasObject(CHAIR,x,y)) && !hayUnaCama(siguiente) && !hasObject(FRIDGE,x,y) && !hasObject(KIT,x,y);
		} else {
			Location robotLocation = getAgPos(NURSE); 
			Location auxiliarLocation = getAgPos(AUXILIAR);
			if ((x==robotLocation.x && y==robotLocation.y) || (x==auxiliarLocation.x && y==auxiliarLocation.y)){
				if(hasObject(CHARGER,x,y)){
					toRet = false;
				}else toRet =  true; 
			}else toRet = isFree(x,y) && !hasObject(WASHER,x,y) && !aTable.contains(siguiente) && !hasObject(BED,x,y) && !hasObject(FRIDGE,x,y) && !hasObject(CHARGER,x,y);
		}
		return toRet;
	}
	

	boolean hayUnaCama(Location siguiente){
		return aBed1.contains(siguiente) || aBed2.contains(siguiente) || aBed3.contains(siguiente);
	}
	


	
	public void añadirLocalizacionVisitada(int Ag, Location loc){
		Set<Location> visitada = localizacionesVisitadas.get(Ag);
		if (visitada == null){
			visitada = new HashSet<>();
			localizacionesVisitadas.put(Ag, visitada);
		}
		visitada.add(loc);
	}

	public boolean haEstado(int Ag, Location loc){
		boolean toRet = false;
		Set<Location> visitada = localizacionesVisitadas.get(Ag);
		if(visitada == null){
			toRet = false;
		}
		else if(visitada.contains(loc)){
			toRet = true;
		}
		return toRet;
	}

	boolean esAdyacente(Location loc1, Location loc2){
		Location arriba = new Location(loc2.x, loc2.y + 1);
        Location abajo = new Location(loc2.x, loc2.y - 1);
        Location izquierda = new Location(loc2.x - 1, loc2.y);
        Location derecha = new Location(loc2.x + 1, loc2.y);

        return loc1.equals(arriba) || loc1.equals(abajo) || loc1.equals(izquierda) || loc1.equals(derecha);
    }


	public void forceMoveAway(int master,int Ag) {
		Location posicionAgente = getAgPos(Ag);
		Location posicionMaster = getAgPos(master);
		if (canMoveTo(Ag,posicionAgente.x+1,posicionAgente.y)) {
			posicionAgente.x++;
			setAgPos(Ag, posicionAgente);
		} else if (canMoveTo(Ag,posicionAgente.x-1,posicionAgente.y)) {
			posicionAgente.x--;
			setAgPos(Ag, posicionAgente);
		} else if (canMoveTo(Ag,posicionAgente.x,posicionAgente.y+1)) {
			posicionAgente.y++;
			setAgPos(Ag, posicionAgente);
		} else if (canMoveTo(Ag,posicionAgente.x,posicionAgente.y-1)) {  
			posicionAgente.y--;
			setAgPos(Ag, posicionAgente);
		} else{
			setAgPos(Ag, posicionMaster);
			setAgPos(master, posicionAgente);
		}
		
		
	}


	boolean moveTowards(int Ag, Location dest) {
		Location posicionAgente = getAgPos(Ag);
		Location posicionInical = getAgPos(Ag);
		Location robotLocation = getAgPos(NURSE);
		Location auxiliarLocation = getAgPos(AUXILIAR);

		if (posicionAgente.distance(dest)>0) { //OWNER
			
			if (posicionAgente.x < dest.x && canMoveTo(Ag,posicionAgente.x+1,posicionAgente.y) && !haEstado(Ag, new Location(posicionAgente.x+1, posicionAgente.y))) {
				if(Ag==OWNER){
					if(posicionInical.x+1==robotLocation.x && posicionInical.y == robotLocation.y){
						forceMoveAway(Ag,NURSE);
					}
				}
				if(Ag==OWNER || Ag==NURSE){
					if(posicionInical.x+1==auxiliarLocation.x && posicionInical.y == auxiliarLocation.y){
						forceMoveAway(Ag,AUXILIAR);
					}
				}
				posicionAgente.x++;
				añadirLocalizacionVisitada(Ag, posicionAgente);
			} else if (posicionAgente.x > dest.x && canMoveTo(Ag,posicionAgente.x-1,posicionAgente.y) && !haEstado(Ag, new Location(posicionAgente.x-1, posicionAgente.y))) {
				if(Ag==OWNER){
					if(posicionInical.x-1==robotLocation.x && posicionInical.y == robotLocation.y){
						forceMoveAway(Ag,NURSE);
					}
				}
				if(Ag==OWNER || Ag==NURSE){ 
					if(posicionInical.x-1==auxiliarLocation.x && posicionInical.y == auxiliarLocation.y){
						forceMoveAway(Ag,AUXILIAR);
					}
				}
				posicionAgente.x--;
				añadirLocalizacionVisitada(Ag, posicionAgente);

			} else if (posicionAgente.y < dest.y && canMoveTo(Ag,posicionAgente.x,posicionAgente.y+1) && !haEstado(Ag, new Location(posicionAgente.x, posicionAgente.y+1))) {
				if(Ag==OWNER){
					if(posicionInical.x==robotLocation.x && posicionInical.y+1 == robotLocation.y){
						forceMoveAway(Ag,NURSE);
					}
				}
				if(Ag==OWNER || Ag==NURSE){ 
					if(posicionInical.x==auxiliarLocation.x && posicionInical.y+1 == auxiliarLocation.y){
						forceMoveAway(Ag,AUXILIAR);
					}
				}
				posicionAgente.y++;
				añadirLocalizacionVisitada(Ag, posicionAgente);
			} else if (posicionAgente.y > dest.y &&  canMoveTo(Ag,posicionAgente.x,posicionAgente.y-1) && !haEstado(Ag, new Location(posicionAgente.x, posicionAgente.y-1))) {  
				if(Ag==OWNER){
					if(posicionInical.x==robotLocation.x && posicionInical.y-1 == robotLocation.y){
						forceMoveAway(Ag,NURSE);
					}
				}
				if(Ag==OWNER || Ag==NURSE){ 
					if(posicionInical.x==auxiliarLocation.x && posicionInical.y-1 == auxiliarLocation.y){
						forceMoveAway(Ag,AUXILIAR);
					}
				}
				posicionAgente.y--;
				añadirLocalizacionVisitada(Ag, posicionAgente);
			}	
		}
		
		if (posicionAgente.equals(posicionInical) && (Ag == NURSE || Ag==AUXILIAR) && posicionAgente.distance(dest)>0) { // Auxiliar y robot esquivan obstaculos
			if (posicionAgente.x == dest.x && canMoveTo(Ag, posicionAgente.x + 1, posicionAgente.y) && !haEstado(Ag, new Location(posicionAgente.x + 1, posicionAgente.y))) {
				posicionAgente.x++;
				añadirLocalizacionVisitada(Ag, posicionAgente);
			} else if (posicionAgente.x == dest.x && canMoveTo(Ag, posicionAgente.x - 1, posicionAgente.y) && !haEstado(Ag, new Location(posicionAgente.x - 1, posicionAgente.y))) {
				posicionAgente.x--;
				añadirLocalizacionVisitada(Ag, posicionAgente);
			} else if (posicionAgente.y == dest.y && canMoveTo(Ag, posicionAgente.x, posicionAgente.y + 1) && !haEstado(Ag, new Location(posicionAgente.x, posicionAgente.y + 1))) {
				posicionAgente.y++;
				añadirLocalizacionVisitada(Ag, posicionAgente);
			} else if (posicionAgente.y == dest.y && canMoveTo(Ag, posicionAgente.x, posicionAgente.y - 1) && !haEstado(Ag, new Location(posicionAgente.x, posicionAgente.y - 1))) {
				posicionAgente.y--;
				añadirLocalizacionVisitada(Ag, posicionAgente);
			}
		}
		
		if (posicionAgente.distance(dest)==1){
			localizacionesVisitadas.clear();
		}
	
		setAgPos(Ag, posicionAgente); // move the agent in the grid 
		
        return true;        
    }

}
