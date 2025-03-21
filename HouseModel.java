//package src.env;

import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Area;
import jason.environment.grid.Location;
//import jason.asSyntax.*;

/** class that implements the Model of Domestic Robot application */
public class HouseModel extends GridWorldModel {

    // constants for the agents
	public static final int NURSE  			=    0;
    public static final int OWNER  			=    1;
    public static final int SUPERMARKET  	=    2;
	
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
	public static final int KIT		= 2048; //Es en potencias porque se esta trabajando con bitmap
	//public static final int DELIVERY, es el que ya viene implementado por almacén, pero yo cree una nueva


    // the grid size                                                     
    public static final int GSize = 12;     //Cells
	public final int GridSize = 1080;    	//Width

	
                          
    boolean fridgeOpen   = false; 	// whether the fridge is open                                   
    boolean carryingBeer = false; 	// whether the robot is carrying beer
    int sipCount        = 0; 		// how many sip the owner did, nos indica tambien si el owner tiene la cerveza en la mano, si aún le quedan sorbos (<10) pues aún la tiene en la mano
    int availableBeers  = 2; 		// how many beers are available

	public final String PARACETAMOL = "paracetamol";
	public final String IBUPROFENO 	= "ibuprofeno";
	public final String DALSI 		= "dalsi";
	public final String FRENADOL 	= "frenadol";
	public final String ASPIRINA 	= "aspirina";

	boolean kitAbierto   		= false; 	// Si el kit esta abierto
	boolean llevandoMedicina 	= false; 	// Si el robot está sujetando una medicina


	int disponibleParacetamol = 5;
	int disponibleIbuprofeno = 5;
	int disponibleDalsi = 5;
	int disponibleFrenadol = 5;
	int disponibleAspirina = 5;

    
	// Initialization of the objects Location on the domotic home scene 
    Location lSofa	 	= new Location(GSize/2, GSize-2);
    Location lChair1  	= new Location(GSize/2+2, GSize-3);
    Location lChair3 	= new Location(GSize/2-1, GSize-3);
    Location lChair2 	= new Location(GSize/2+1, GSize-4); 
    Location lChair4 	= new Location(GSize/2, GSize-4); 
    Location lDeliver 	= new Location(0, GSize-1);
    Location lWasher 	= new Location(GSize/3, 0);	
    Location lFridge 	= new Location(2, 0);

	Location lKit 		= new Location(0, 0);

    Location lTable  	= new Location(GSize/2, GSize-3);
	Location lBed2		= new Location(GSize+2, 0);
	Location lBed3		= new Location(GSize*2-3,0);
	Location lBed1		= new Location(GSize+1, GSize*3/4);

	// Initialization of the doors location on the domotic home scene 
	Location lDoorHall 		= new Location(0, GSize-1);  
	Location lDoorKit_Hall	= new Location(0, GSize/2);
	Location lDoorKit_HW	= new Location(GSize/2+1, GSize/2-1); 
	Location lDoorLivi_Hall	= new Location(GSize/4, GSize-1);  
	Location lDoorLivi_HW	= new Location(GSize/2+2, GSize/2);
	Location lDoorBed_P		= new Location(GSize+1, GSize/2);
	Location lDoorBed_I1	= new Location(GSize+1, GSize/4+1);
	Location lDoorBed_I2	= new Location(GSize*2-1, GSize/4+1);
	Location lDoorBath_BedP	= new Location(GSize*2-4, GSize/2+1); 	 	 	
	Location lDoorBath_HW	= new Location(GSize-1, GSize/4+1);
	
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
	/*
	Modificar el modelo para que la casa sea un conjunto de habitaciones
	Dar un codigo a cada habitación y vincular un Area a cada habitación
	Identificar los objetos de manera local a la habitación en que estén
	Crear un método para la identificación del tipo de agente existente
	Identificar objetos globales que precisen de un único identificador
	*/
	
    public HouseModel() {
        // create a GSize x 2GSize grid with 3 mobile agent
        super(2*GSize, GSize, 2);
                                                                           
        // Initial location for the owner and the nurse
        setAgPos(NURSE, 2, 4);  
		setAgPos(OWNER, GSize/2+2, GSize-3);

		// Location of the furniture of the house
        add(FRIDGE, lFridge); 
		add(KIT, lKit); 
		add(WASHER, lWasher); 
		add(DOOR,   lDeliver); 
		add(SOFA,   lSofa);
		add(CHAIR,  lChair2);
		add(CHAIR,  lChair3);
		add(CHAIR,  lChair4);
        add(CHAIR,  lChair1);  
        add(TABLE,  lTable);  
		add(BED,	lBed1);
		add(BED,	lBed2);
		add(BED,	lBed3);

		// Locations of doors
		add(DOOR, lDoorHall);
		add(DOOR, lDoorKit_Hall);
		add(DOOR, lDoorKit_HW);
		add(DOOR, lDoorLivi_Hall);
		add(DOOR, lDoorLivi_HW);
		add(DOOR, lDoorBed_P);
		add(DOOR, lDoorBed_I1);
		add(DOOR, lDoorBed_I2);
		add(DOOR, lDoorBath_BedP);
		add(DOOR, lDoorBath_HW);

		//Location of walls
		addWall(GSize/2+1, 0, GSize/2+1, GSize/2-2);  		
		addWall(GSize/2+1, GSize/4+1, GSize-2, GSize/4+1);   
		addWall(GSize+2, GSize/4+1, GSize*2-2, GSize/4+1);   
		addWall(GSize*2-6, 0, GSize*2-6, GSize/4);
		addWall(GSize, 0, GSize, GSize/4+1);  
		addWall(1, GSize/2, GSize/2+1, GSize/2);            
		addWall(GSize/4, GSize/2+1, GSize/4, GSize-2);            
		addWall(GSize, GSize/2, GSize, GSize-1);  
		addWall(GSize*2-4, GSize/2+2, GSize*2-4, GSize-1);  
		addWall(GSize/2+3, GSize/2, GSize*2-1, GSize/2);  
 		
		 
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
        if (!fridgeOpen) {
            fridgeOpen = true;
            return true;
        } else {
            return false;
        }
    }

    boolean closeFridge() {
        if (fridgeOpen) {
            fridgeOpen = false;
            return true;
        } else {
            return false;
        }
    }  
	
	boolean abrirKit() {
        if (!kitAbierto) {
            kitAbierto = true;
            return true;
        } else {
            return false;
        }
    }

    boolean cerrarKit() {
        if (kitAbierto) {
            kitAbierto = false;
            return true;
        } else {
            return false;
        }
    } 

	boolean canMoveTo (int Ag, int x, int y) {
		if (Ag == NURSE) {
			return (isFree(x,y) && !hasObject(WASHER,x,y) && !hasObject(TABLE,x,y) &&
		           !hasObject(SOFA,x,y) && !hasObject(CHAIR,x,y));
		} else { 
			
			return (isFree(x,y) && !hasObject(WASHER,x,y) && !hasObject(TABLE,x,y));
		}
	}
	
	boolean moveTowards(int Ag, Location dest){
		Location posicionAgente = getAgPos(Ag);
		Location posicionAntigua = getAgPos(Ag);
		String habitacionActual = getRoom(posicionAgente);
		String habitacionAgente = getRoom(posicionAgente);
		String habitacionDestino = getRoom(dest);

		if(habitacionAgente == habitacionDestino){
			System.out.println("Estoy en la misma habitación");
			if (posicionAgente.distance(dest)>0) {
				if (posicionAgente.x < dest.x && canMoveTo(Ag,posicionAgente.x+1,posicionAgente.y)) {
					posicionAgente.x++;
				} else if (posicionAgente.x > dest.x && canMoveTo(Ag,posicionAgente.x-1,posicionAgente.y)) {
					posicionAgente.x--;
				} else if (posicionAgente.y < dest.y && posicionAgente.distance(dest)>0 && canMoveTo(Ag,posicionAgente.x,posicionAgente.y+1)) {
					posicionAgente.y++;
				} else if (posicionAgente.y > dest.y && posicionAgente.distance(dest)>0 && canMoveTo(Ag,posicionAgente.x,posicionAgente.y-1)) {  
					posicionAgente.y--;
				}
			}
		} else{
			// aqui escogemos que puerta esta más cerca de nuesto destino y avanzamos hacia ella en busca de la habitación destino
			Location puertaSiguiente = mejorPuerta(Ag, dest);
			if (posicionAgente.distance(puertaSiguiente)>0) {
				if (posicionAgente.x < puertaSiguiente.x && canMoveTo(Ag,posicionAgente.x+1,posicionAgente.y)) {
					posicionAgente.x++;
				} else if (posicionAgente.x > puertaSiguiente.x && canMoveTo(Ag,posicionAgente.x-1,posicionAgente.y)) {
					posicionAgente.x--;
				} else if (posicionAgente.y < puertaSiguiente.y && posicionAgente.distance(puertaSiguiente)>0 && canMoveTo(Ag,posicionAgente.x,posicionAgente.y+1)) {
					posicionAgente.y++;
				} else if (posicionAgente.y > puertaSiguiente.y && posicionAgente.distance(puertaSiguiente)>0 && canMoveTo(Ag,posicionAgente.x,posicionAgente.y-1)) {  
					posicionAgente.y--;
				}

			} else if(posicionAgente.distance(puertaSiguiente) == 0){
				Location abajo = new Location(puertaSiguiente.x, puertaSiguiente.y-1);
				Location arriba = new Location(puertaSiguiente.x, puertaSiguiente.y+1);
				Location izquierda = new Location(puertaSiguiente.x-1, puertaSiguiente.y);
				Location derecha = new Location(puertaSiguiente.x+1, puertaSiguiente.y);

				if (canMoveTo(Ag,derecha.x,derecha.y) && habitacionActual != getRoom(derecha)) {
					posicionAgente.x++;
					habitacionActual = getRoom(derecha);
				} else if (canMoveTo(Ag,izquierda.x-1,izquierda.y) && habitacionActual != getRoom(izquierda)) {
					posicionAgente.x--;
					habitacionActual = getRoom(izquierda);
				} else if (canMoveTo(Ag,arriba.x,arriba.y+1) && habitacionActual != getRoom(arriba)) {
					posicionAgente.y++;
					habitacionActual = getRoom(arriba);
				} else if (canMoveTo(Ag,abajo.x,abajo.y-1) && habitacionActual != getRoom(abajo)) {  
					posicionAgente.y--;
					habitacionActual = getRoom(abajo);
				}
			}
		}
		if (posicionAgente.equals(posicionAntigua) && posicionAgente.distance(dest) > 0) {
			
			//SI NO SE PUEDE MOVER A ABAJO
			if (!canMoveTo(Ag, posicionAgente.x, posicionAgente.y-1) & canMoveTo(Ag, posicionAgente.x+1, posicionAgente.y)) {
				posicionAgente.x++; // Intentar moverse derecha
			}else if(!canMoveTo(Ag, posicionAgente.x, posicionAgente.y-1) & canMoveTo(Ag, posicionAgente.x-1, posicionAgente.y)) {
				posicionAgente.x--; // Intentar moverse izquierda
			}
			//SI NO SE PUEDE MOVER A ARRIBA
			if (!canMoveTo(Ag, posicionAgente.x, posicionAgente.y+1) & canMoveTo(Ag, posicionAgente.x+1, posicionAgente.y)) {
				posicionAgente.x++; // Intentar moverse derecha
			}else if(!canMoveTo(Ag, posicionAgente.x, posicionAgente.y+1) & canMoveTo(Ag, posicionAgente.x-1, posicionAgente.y)) {
				posicionAgente.x--; // Intentar moverse izquierda
			}
			//SI NO SE PUEDE MOVER A LA DERECHA
			if (!canMoveTo(Ag, posicionAgente.x+1, posicionAgente.y) & canMoveTo(Ag, posicionAgente.x, posicionAgente.y+1)) {
				posicionAgente.y++; // Intentar moverse arriba
			}else if (!canMoveTo(Ag, posicionAgente.x+1, posicionAgente.y) & canMoveTo(Ag, posicionAgente.x, posicionAgente.y-1)) {
				posicionAgente.y--; // Intentar moverse abajo
			}
			//SI NO SE PUEDE MOVER A LA IZQUIERDA
			if (!canMoveTo(Ag, posicionAgente.x-1, posicionAgente.y) & canMoveTo(Ag, posicionAgente.x, posicionAgente.y+1)) {
				posicionAgente.y++; // Intentar moverse arriba
			}else if (!canMoveTo(Ag, posicionAgente.x-1, posicionAgente.y) & canMoveTo(Ag, posicionAgente.x, posicionAgente.y-1)) {
				posicionAgente.y--; // Intentar moverse abajo
			}
		}
		setAgPos(Ag, posicionAgente);

		return true;
	}          

	Location mejorPuerta(int Ag, Location dest) {
		Location posicionAgente = getAgPos(Ag);
		String habitacionActual = getRoom(posicionAgente);
		Location[] puertas;

		
	
		switch (habitacionActual) {
			case "kitchen":
				puertas = new Location[]{lDoorKit_Hall, lDoorKit_HW};
				break;
			case "hall":
				puertas = new Location[]{lDoorHall, lDoorLivi_Hall, lDoorKit_Hall};
				break;
			case "livingroom":
				puertas = new Location[]{lDoorLivi_Hall, lDoorLivi_HW};
				break;
			case "hallway":
				puertas = new Location[]{lDoorKit_HW, lDoorLivi_HW, lDoorBed_P, lDoorBed_I1, lDoorBed_I2, lDoorBath_HW};
				break;
			case "bath1":
				puertas = new Location[]{lDoorBath_HW};
				break;
			case "bedroom2":
				puertas = new Location[]{lDoorBed_I1};
				break;
			case "bedroom3":
				puertas = new Location[]{lDoorBed_I2};
				break;
			case "bedroom1":
				puertas = new Location[]{lDoorBed_P, lDoorBath_BedP};
				break;
			case "bath2":
				puertas = new Location[]{lDoorBath_BedP};
				break;
			default:
				puertas = new Location[]{};
				break;
		}
	
		Location mejorPuerta = puertas[0];
		int menorDistancia = posicionAgente.distance(puertas[0]) + puertas[0].distance(dest);
	
		for (Location puerta : puertas) {
			int distancia = posicionAgente.distance(puerta) + puerta.distance(dest);
			if (distancia < menorDistancia) {
				menorDistancia = distancia;
				mejorPuerta = puerta;
			}
		}
	
		return mejorPuerta;
	}
	
    boolean getBeer() {
        if (fridgeOpen && availableBeers > 0 && !carryingBeer) {
            availableBeers--;
            carryingBeer = true;
            return true;
        } else if (fridgeOpen && availableBeers < 0 && !carryingBeer){
			System.out.println("There is no beers in the friedge.");
			
			return false;
		}
		
		else {  
			if (fridgeOpen) {
				System.out.println("The fridge is opened. ");
			};
			if (availableBeers > 0){ 
				System.out.println("The fridge has Beers enough. ");
			};
			if (!carryingBeer){ 
				System.out.println("The robot is not bringing a Beer. ");
			};
            return false;
        }
    }

	boolean getMedicina(String medicina) { //Falta comprobar que hay disponibilidad de medicinas antes de cojerlas
		if(kitAbierto && !llevandoMedicina){
			if(medicina==PARACETAMOL){
				disponibleParacetamol--;
			}
			else if(medicina==IBUPROFENO){
				disponibleIbuprofeno--;
			}
			else if(medicina==DALSI){
				disponibleDalsi--;
			}
			else if(medicina==FRENADOL){
				disponibleFrenadol--;
			}
			else if(medicina==ASPIRINA){
				disponibleAspirina--;
			}else return false;
			System.out.println(mostrarMedicinas());
			return true;
		}else{
			System.out.println("O kit no abierto o se esta llevando medicina");
			return false;
		}
    }

	String mostrarMedicinas(){
		StringBuilder  toRet = new StringBuilder();
		toRet.append("Kit:\n");
		toRet.append(PARACETAMOL).append(": "+Integer.toString(disponibleParacetamol)).append("\n");
		toRet.append(IBUPROFENO).append(": "+Integer.toString(disponibleIbuprofeno)).append("\n");
		toRet.append(DALSI).append(": "+Integer.toString(disponibleDalsi)).append("\n");
		toRet.append(FRENADOL).append(": "+Integer.toString(disponibleFrenadol)).append("\n");
		toRet.append(ASPIRINA).append(": "+Integer.toString(disponibleAspirina));
		return toRet.toString();
	}

    boolean addBeer(int n) {
        availableBeers += n;
        //if (view != null)
        //    view.update(lFridge.x,lFridge.y);
        return true;
    }

    boolean handInBeer() {
        if (carryingBeer) {
            sipCount = 10;
            carryingBeer = false;
            //if (view != null)
                //view.update(lOwner.x,lOwner.y);
            return true;
        } else {
            return false;
        }
    }

    boolean sipBeer() {
        if (sipCount > 0) {
            sipCount--;
            //if (view != null)
                //view.update(lOwner.x,lOwner.y);
            return true;
        } else {
            return false;
        }
    }

	 /**
     * Verifica si un agente está adyacente a una localización dada.
     *
     * Este método comprueba si la posición de un agente (Ag) se encuentra en una de las
     * posiciones adyacentes a la localización proporcionada (loc). Las posiciones adyacentes
     * se definen como las posiciones directamente arriba, abajo, izquierda o derecha de la
     * localización dada.
     *
     * @param Ag El identificador del agente.
     * @param loc La localización que se va a verificar si está adyacente al agente.
     * @return true si el agente está en una posición adyacente a la localización;
     *         false en caso contrario.
     */
    boolean agIsAdyacent (int Ag, Location loc)
    {
        Location agentPos = getAgPos(Ag);
        if(agentPos.x == loc.x-1 && agentPos.y == loc.y //está a la izquierda de la localización.
            | agentPos.x == loc.x+1 && agentPos.y == loc.y //está a la derecha de la localización.
            | agentPos.x == loc.x && agentPos.y == loc.y-1 //está a la arriba de la localización.
            | agentPos.x == loc.x && agentPos.y == loc.y+1 //está a la abajo de la localización.
            ){
                return true;
            } else
                {
                    return false;
                }      
    }

    /**
     * Verifica si dos localizaciones son adyacentes.
     *
     * Este método determina si las localizaciones l1 y l2 son adyacentes. Las localizaciones
     * se consideran adyacentes si están en una de las posiciones directamente arriba, abajo,
     * izquierda o derecha una de la otra.
     *
     * @param l1 La primera localización.
     * @param l2 La segunda localización.
     * @return true si las dos localizaciones son adyacentes; false en caso contrario.
     */
    boolean LocIsAdyacent (Location l1, Location l2)
    {
        if(l1.x == l2.x-1 && l1.y == l2.y //está a la izquierda de la localización.
            | l1.x == l2.x+1 && l1.y == l2.y //está a la derecha de la localización.
            | l1.x == l2.x && l1.y == l2.y-1 //está a la arriba de la localización.
            | l1.x == l2.x && l1.y == l2.y+1 //está a la abajo de la localización.
            ){
                return true;
            } else
                {
                    return false;
                }      
    }



}
