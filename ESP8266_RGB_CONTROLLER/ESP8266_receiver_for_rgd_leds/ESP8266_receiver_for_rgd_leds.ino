#include <SlipMassagePacker.h>
#include <SlipMassageParser.h>

#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <OSCMessage.h>
#include <OSCBundle.h>
#include <OSCData.h>

WiFiUDP Udp;
const unsigned int localPort = 12000;

OSCErrorCode error;
unsigned int ledState = LOW;              // LOW means led is *on*

SlipMassagePacker outbound;
SlipMassageParser inbound;

int R = 0, G = 0, B = 0;

void setup()
{
    pinMode(BUILTIN_LED, OUTPUT);
    digitalWrite(BUILTIN_LED, ledState);    // turn *on* led
    
  //  Serial.begin(115200);
    Serial.begin(9600);
    IPAddress ip(192,168,0,55); //static IP address
    IPAddress gateway(192,168,0,1); //Router's IP address
    IPAddress subnet(255, 255, 255, 0);
    WiFi.config(ip, gateway, subnet);
    
    Serial.println();

    WiFi.hostname("Robot_Kinois");
    WiFi.begin("JMDE", "kinsafariafrica9");
  
    Serial.print("Connecting");
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.println(".");
    }
    Serial.println();
  
    Serial.println("Connected, IP address: ");
    Serial.println(WiFi.localIP());
  
    Serial.println("Starting UDP");
    Udp.begin(localPort);
    Serial.println("Local Port: ");
    Serial.print(Udp.localPort());
}

void loop()
{
    OSCMessage msg;
    int size = Udp.parsePacket();
    // RECEIVE OSC DATA OVER WIFI AND DISPATCH TO THE CORRECT METHOD.
    if (size > 0)
    {
        while(size--)
        {
            msg.fill(Udp.read());
        }
        if (!msg.hasError())
        {
            msg.dispatch("/led", led);
        }
        else
        {
            error = msg.getError();
            Serial.print("error: ");
            Serial.print(error);
        }
    }
}

void led(OSCMessage &msg)
{
    R = msg.getInt(0);
    G = msg.getInt(1);
    B = msg.getInt(2);

//    Serial.println(msg.getInt(0));
//    Serial.println(msg.getInt(1));
//    Serial.println(msg.getInt(2));

    //PACKING RECEIVED OSC DATA TO SEND TO ARDUINO
    outbound.beginPacket("RGB_VALUES"); // START A PACKET WITH ADDRESS "RGB_VALUES"
    outbound.addInt(R);                 // ADD RED VALUE
    outbound.addInt(G);                 // ADD GREEN VALUE
    outbound.addInt(B);                 // ADD BLUE VALUE
    outbound.endPacket();               // END THE PACKET
    // SEND THE VALUE TO ARDUINO VIA SERIAL
    Serial.write( outbound.buffer(), outbound.size() );
}
