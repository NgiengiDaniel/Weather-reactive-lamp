import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress remoteLocation;
float accelerometerX, accelerometerY, accelerometerZ;


//////////////////////////
Button on_button;  // the button
int clk = 1;       // number of times the button is clicked
//////////////////////////
int r, g, b;
HScrollbar hs1, hs2, hs3;
//////////////////////////

void setup() 
{
      size( 480, 960 );
      //fullScreen();
      orientation(PORTRAIT);
      oscP5 = new OscP5( this, 12000 );
      remoteLocation = new NetAddress( "192.168.0.55"/*"192.168.0.27"*//*"192.168.0.24"*/, 12000 );  
      textAlign( CENTER, CENTER );
      textSize( 24 );
      
      //hs1 = new HScrollbar(20, 20, 40, 16, 16);
      fill(255, 0, 0);
      hs1 = new HScrollbar(0, 200, width, 80, 16);
      hs2 = new HScrollbar(0, 400, width, 80, 16);
      hs3 = new HScrollbar(0, 600, width, 80, 16);
     //////////////////
     
     //////////////////
     on_button = new Button("Click Me", width /2, height - height /3, 400, 120);
     //////////////////
}

void draw() 
{
      background( 33, 47, 60  );
      text(""+(int)map(hs1.getPos(), 0, width, 0, 256), 70, 180);
      
      //////////
      if (on_button.MouseIsOver()) 
      {
        //on_button.fill(0,0,0);
      }
      on_button.Draw();
      hs1.update();
      hs2.update();
      hs3.update();
      hs1.display();
      hs2.display();
      hs3.display();
      
      ////////
      //System.out.println((int)red_s.getValue());
      r = (int)map(hs1.getPos(), 0, width, 0, 256);
      g = (int)map(hs2.getPos(), 0, width, 0, 256);
      b = (int)map(hs3.getPos(), 0, width, 0, 256);
      //System.out.println( oscP5. );
}

//void oscEvent(OscMessage theOscMessage) 
//{
//      if ( theOscMessage.checkTypetag( "fff" ) )                  
//      {
//            accelerometerX =  theOscMessage.get( 0 ).floatValue();  
//            accelerometerY =  theOscMessage.get( 1 ).floatValue();
//            accelerometerZ =  theOscMessage.get( 2 ).floatValue();
//      }
//}


void mousePressed()
{
  if (on_button.MouseIsOver()) 
  {
      OscMessage myMessage = new OscMessage( "/led" );                             
      myMessage.add( r );
      myMessage.add( g );
      myMessage.add( b );
      oscP5.send( myMessage, remoteLocation ); 
  }
}

////////////////////////////////////////////////

class Button 
{
  String label;
  float x;    // top left corner x position
  float y;    // top left corner y position
  float w;    // width of button
  float h;    // height of button
  color c;
  
  Button(String labelB, float xpos, float ypos, float widthB, float heightB) 
  {
    label = labelB;
    x = xpos - widthB/2;
    y = ypos - heightB/2;
    w = widthB;
    h = heightB;
  }
  
  void Draw() 
  {
    fill(255);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    textSize(50);
    fill(0);
    text(label, x + (w / 2), y + (h / 2));
  }
  
  boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) 
    {
      return true;
    }
    return false;
  }
}
////////////////////////////////////////////////

class HScrollbar 
{
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;

  HScrollbar (float xp, float yp, int sw, int sh, int l) 
  {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
  }

  void update() 
  {
    if (overEvent()) 
    {
      over = true;
    } 
    else 
    {
      over = false;
    }
    if (mousePressed && over) 
    {
      locked = true;
    }
    if (!mousePressed) 
    {
      locked = false;
    }
    if (locked) 
    {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1)
    {
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) 
  {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() 
  {
    if (mouseX > xpos && mouseX < xpos+swidth &&
       mouseY > ypos && mouseY < ypos+sheight) 
    {
      return true;
    } 
    else 
    {
      return false;
    }
  }

  void display() 
  {
    noStroke();
    fill(204);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) 
    {
      fill(0, 0, 0);
    } 
    else 
    {
      fill(102, 102, 102);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }
}
////////////////////////////////////////////////
