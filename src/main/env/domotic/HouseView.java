package domotic;

import jason.environment.grid.*;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.net.URL;
import java.nio.file.Paths;

import javax.swing.ImageIcon;

public class HouseView extends GridWorldView {

    HouseModel hmodel;
	int viewSize;
	String currentDirectory;

    public HouseView(HouseModel model) {
		super(model, "Domestic Care Robot", model.GridSize);
        hmodel = model;
		viewSize = model.GridSize;
		setSize(viewSize, viewSize/2);
        defaultFont = new Font("Arial", Font.BOLD, 14);
        setVisible(true);
        repaint();
		currentDirectory = Paths.get("").toAbsolutePath().toString();
    }

    @Override
    public void draw(Graphics g, int x, int y, int object) {
        Location lRobot = hmodel.getAgPos(0);
		Location lOwner = hmodel.getAgPos(1);
		Location lAuxiliar = hmodel.getAgPos(3);
		Location loc  	= new Location(x, y);
		String objPath = currentDirectory;
		g.setColor(Color.white);
		super.drawEmpty(g, x, y);
		switch (object) {
		case HouseModel.BED:
 			g.setColor(Color.lightGray);
			if (hmodel.lBed1.equals(loc)) {
				drawMultipleScaledImage(g, x, y, "/doc/doubleBedlt.png", 2, 2, 100, 100);
				g.setColor(Color.red);
				super.drawString(g, x, y, defaultFont, " 1 ");
			};
			if (hmodel.lBed2.equals(loc)) {  
				objPath = "/doc/singleBed.png";
				drawMultipleScaledImage(g, x, y, objPath, 2, 2, 60, 90); 
				g.setColor(Color.red);
				super.drawString(g, x, y, defaultFont, " 2 ");
			};
			if (hmodel.lBed3.equals(loc)) {
				objPath = "/doc/singleBed.png";
				drawMultipleScaledImage(g, x, y, objPath, 2, 2, 60, 90); 
				g.setColor(Color.red);
				super.drawString(g, x, y, defaultFont, " 3 ");
			};
            break;                                                                                                  
		case HouseModel.CHAIR:
 			g.setColor(Color.lightGray);
			if (hmodel.lChair1.equals(loc)) {              
				objPath = "/doc/chairL.png";
				drawScaledImageMd(g, x, y, objPath,80,80);
			};
			if (hmodel.lChair2.equals(loc)) {  
				objPath = "/doc/chairD.png";
				drawScaledImageMd(g, x, y, objPath,80,80); 
			};
			if (hmodel.lChair4.equals(loc)) {  
				objPath = "/doc/chairD.png";
				drawScaledImageMd(g, x, y, objPath,80,80); 
			};
			if (hmodel.lChair3.equals(loc)) {
				objPath = "/doc/chairU.png";
				drawScaledImageMd(g, x, y, objPath,80,80);
			};
            break;                                                                                                  
		case HouseModel.SOFA:                                                                                      
            g.setColor(Color.lightGray);
			objPath = "/doc/sofa.png";
			drawMultipleScaledImage(g, x, y, objPath, 2, 1, 90, 90);
            break; 
		case HouseModel.TABLE:
            g.setColor(Color.lightGray);
			objPath = "/doc/table.png";
			drawMultipleScaledImage(g, x, y, objPath, 2, 1, 80, 80);
            break;              
		case HouseModel.DOOR:
			g.setColor(Color.lightGray);
			if (lRobot.equals(loc) || lOwner.equals(loc) ) {
				objPath = "/doc/openDoor2.png";
				drawScaledImage(g, x, y, objPath, 75, 100);
            } else {   
				objPath = "/doc/closeDoor2.png";
				drawScaledImage(g, x, y, objPath, 75, 100);				
			}           
            break;
		case HouseModel.WASHER:
			g.setColor(Color.lightGray);
			if (lRobot.equals(hmodel.lWasher)) {
				objPath = "/doc/openWasher.png";
				drawScaledImage(g, x, y, objPath, 50, 60);
            } else {
				objPath = "/doc/closeWasher.png";
				drawImage(g, x, y, objPath);			
			}           
            break;
		case HouseModel.CHARGER:
			g.setColor(Color.lightGray);
			if(lRobot.equals(hmodel.lCharger) || lAuxiliar.equals(hmodel.lCharger)){
				objPath = "/doc/chargerStationUsed.png";
				drawScaledImage(g, x, y, objPath, 50, 50 );
			} else {
				objPath = "/doc/chargerStation.png";
				drawScaledImage(g, x, y, objPath, 50, 50 );
			}
		break;
        case HouseModel.FRIDGE:
            g.setColor(Color.lightGray); 
			if (lRobot.isNeigbour(hmodel.lFridge) || (lOwner.isNeigbour(hmodel.lFridge))) { 
				objPath = "/doc/openNevera.png";
				drawImage(g, x, y, objPath);
				g.setColor(Color.yellow);
            } else {   
				objPath = "/doc/closeNevera.png";
				drawImage(g, x, y, objPath);	
				g.setColor(Color.blue);
			}                      
            break;
		case HouseModel.KIT:
            g.setColor(Color.lightGray); 
			if (lRobot.isNeigbour(hmodel.lKit) || lOwner.isNeigbour(hmodel.lKit) || lAuxiliar.isNeigbour(hmodel.lKit)) { 
				objPath = "/doc/kitOpen.png";
				drawImage(g, x, y, objPath);
            } else {   
				objPath = "/doc/kitClosed.png";
				drawImage(g, x, y, objPath);	
			}                      
            break; 
		}

        repaint();
    }
                          
    @Override
    public void drawAgent(Graphics g, int x, int y, Color c, int id) {
        Location lRobot = hmodel.getAgPos(0);
        Location lOwner = hmodel.getAgPos(1);
		Location lAuxiliar = hmodel.getAgPos(3);
		String objPath = currentDirectory;

		if (id < 1) { 
            if (!lRobot.equals(lOwner) && !lRobot.equals(hmodel.lFridge)) {
                c = Color.yellow;
                objPath = "/doc/bot.png";
                drawImage(g,x,y,objPath);
                g.setColor(Color.black);
                super.drawString(g, x, y, defaultFont, "Rob");
            }
        } else if (id == 3) {
			objPath = "/doc/auxiliar.png";
					drawImage(g,x,y,objPath);
		}  else { 
			if (lOwner.equals(hmodel.lChair1)) {
				drawMan(g, hmodel.lChair1.x, hmodel.lChair1.y, "left"); 
			} else if (lOwner.equals(hmodel.lChair2)) {
				drawMan(g, hmodel.lChair2.x, hmodel.lChair2.y, "down");
			} else if (lOwner.equals(hmodel.lChair4)) {
				drawMan(g, hmodel.lChair4.x, hmodel.lChair4.y, "down");
			} else if (lOwner.equals(hmodel.lChair3)) {      
				drawMan(g, hmodel.lChair3.x, hmodel.lChair3.y, "right");    
			} else if (lOwner.equals(hmodel.lSofa)) {
				drawMan(g, hmodel.lSofa.x, hmodel.lSofa.y, "up");    
			} else if (lOwner.equals(hmodel.lDeliver)) {
				g.setColor(Color.lightGray); 
				objPath = "/doc/openDoor2.png";
				drawScaledImage(g, x, y, objPath, 75, 100);
				drawMan(g, x, y, "down");
			} else {
				drawMan(g, x, y, "walkr");         
			};                                                         
		}			        
    } 
	
    public void drawMultipleObstacleH(Graphics g, int x, int y, int NCells) {
		for (int i = x; i < x+NCells; i++) {
                drawObstacle(g,i,y); 
            }    
	}

    public void drawMultipleObstacleV(Graphics g, int x, int y, int NCells) {
		for (int j = y; j < y+NCells; j++) {
                drawObstacle(g,x,j);
            }    
    }

    public void drawMultipleImage(Graphics g, int x, int y, String imageAddress, int NW, int NH) {
		URL url = getClass().getResource(imageAddress);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image! "+imageAddress);
		else 
			Img = new ImageIcon(getClass().getResource(imageAddress)); 
		g.setColor(Color.lightGray);
		g.drawImage(Img.getImage(), x * cellSizeW + 2, y * cellSizeH + 2, NW*cellSizeW - 4, NH*cellSizeH - 4, null);
    }

    public void drawMultipleScaledImage(Graphics g, int x, int y, String imageAddress, int NW, int NH, int scaleW, int scaleH) {
		URL url = getClass().getResource(imageAddress);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image! "+imageAddress);
		else Img = new ImageIcon(getClass().getResource(imageAddress)); 
		g.setColor(Color.lightGray);
		g.drawImage(Img.getImage(), x * cellSizeW + NW*cellSizeW*(100-scaleW)/200, y * cellSizeH + NH*cellSizeH*(100-scaleH)/200 + 1, NW*cellSizeW*scaleW/100, NH*scaleH*cellSizeH/100, null);
    }
	
    public void drawScaledImage(Graphics g, int x, int y, String imageAddress, int scaleW, int scaleH) {
		URL url = getClass().getResource(imageAddress);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image!"+imageAddress);
		else Img = new ImageIcon(getClass().getResource(imageAddress));
		g.setColor(Color.lightGray);
		g.drawImage(Img.getImage(), x * cellSizeW + cellSizeW*(100-scaleW)/200, y * cellSizeH + cellSizeH*(100-scaleH)/100, cellSizeW*scaleW/100, scaleH*cellSizeH/100, null);
    }

    public void drawScaledImageUp(Graphics g, int x, int y, String imageAddress, int scaleW, int scaleH) {
		URL url = getClass().getResource(imageAddress);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image! "+imageAddress);
		else Img = new ImageIcon(getClass().getResource(imageAddress));
		g.setColor(Color.lightGray);
		g.drawImage(Img.getImage(), x * cellSizeW + cellSizeW*(100-scaleW)/200, y * cellSizeH + 2, cellSizeW*scaleW/100, scaleH*cellSizeH/100, null);
    }
	
    public void drawScaledImageLf(Graphics g, int x, int y, String imageAddress, int scaleW, int scaleH) {
		URL url = getClass().getResource(imageAddress);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image! "+imageAddress);
		else Img = new ImageIcon(getClass().getResource(imageAddress)); 
		g.setColor(Color.lightGray);
		g.drawImage(Img.getImage(), x * cellSizeW, y * cellSizeH + cellSizeH*(100-scaleH)/200 + 1, cellSizeW*scaleW/100, scaleH*cellSizeH/100, null);
    }
	
    public void drawScaledImageRt(Graphics g, int x, int y, String imageAddress, int scaleW, int scaleH) {
		URL url = getClass().getResource(imageAddress);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image! "+imageAddress);
		else Img = new ImageIcon(getClass().getResource(imageAddress));
		g.setColor(Color.lightGray);
		g.drawImage(Img.getImage(), x * cellSizeW + cellSizeW*(100-scaleW)/100, y * cellSizeH + cellSizeH*(100-scaleH)/200 + 1, cellSizeW*scaleW/100, scaleH*cellSizeH/100, null);
    }
	
    public void drawScaledImageMd(Graphics g, int x, int y, String imageAddress, int scaleW, int scaleH) {
		URL url = getClass().getResource(imageAddress);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image! "+imageAddress);
		else Img = new ImageIcon(getClass().getResource(imageAddress));
		g.setColor(Color.lightGray);
		g.drawImage(Img.getImage(), x * cellSizeW + cellSizeW*(100-scaleW)/200, y * cellSizeH + cellSizeH*(100-scaleH)/200 + 1, cellSizeW*scaleW/100, scaleH*cellSizeH/100, null);
    }

    public void drawImage(Graphics g, int x, int y, String imageAddress) {
		URL url = getClass().getResource(imageAddress);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image! "+imageAddress);
		else Img = new ImageIcon(getClass().getResource(imageAddress));
		g.drawImage(Img.getImage(), x * cellSizeW+1, y * cellSizeH+1, cellSizeW-2, cellSizeH-2, null);
    }
	
    public void drawMan(Graphics g, int x, int y, String how) { 
		String resource = "/doc/sitd.png";
		switch (how) {
			case "right": resource = "/doc/sitr.png"; 
			break;
			case "left": resource = "/doc/sitl.png";  
			break;     
			case "up": resource = "/doc/situ.png";  
			break;     
			case "down": resource = "/doc/sitd.png"; 
			break;
			case "stand": resource = "/doc/sits.png"; 
			break;
			case "walkr": resource = "/doc/walklr.png"; 
			break;
        }
		URL url = getClass().getResource(resource);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image! "+resource);
		else Img = new ImageIcon(getClass().getResource(resource));
		g.drawImage(Img.getImage(), x * cellSizeW + 1, y * cellSizeH + 1, cellSizeW - 3, cellSizeH - 3, null);
    }
        
    public void drawManSittingRight(Graphics g, int x, int y) {
		String objPath = "/doc/sitr.png";
		URL url = getClass().getResource(objPath);
		ImageIcon Img = new ImageIcon();
		if (url == null)
    		System.out.println( "Could not find image! "+objPath);
		else Img = new ImageIcon(getClass().getResource(objPath)); 
		g.drawImage(Img.getImage(), x * cellSizeW - 4, y * cellSizeH + 1, cellSizeW + 2, cellSizeH - 2, null);
    }
        
    public void drawSquare(Graphics g, int x, int y) {
        g.setColor(Color.blue);
        g.drawRect(x * cellSizeW + 2, y * cellSizeH + 2, cellSizeW - 4, cellSizeH - 4);
        g.setColor(Color.cyan);
        g.drawRect(x * cellSizeW + 1, y * cellSizeH + 1, cellSizeW - 3, cellSizeH - 3);   
    }   
	
}