#include <EEPROM.h>
#include <ReceiveOnlySoftwareSerial.h>
#include <SlipMassagePacker.h>
#include <SlipMassageParser.h>

ReceiveOnlySoftwareSerial serial(2);

volatile uint8_t* Port[] = {&OCR0A, &OCR0B, &OCR1B};
int Pin[] = {0, 1, 4};

SlipMassageParser inbound;
int R = 125, G = 125, B = 125;

void setup() 
{
  pinMode(3, INPUT);                                                                                                                                                   //                  _______      
  pinMode(0, OUTPUT);                            //RED pin is PB0                                          //PB5--RESET PULLED UP TO +5V     |              |     VCC    +5V
  pinMode(1, OUTPUT);                           //GREEN pin is PB1                                                                              PB3--               |             |     PB2     RX, taking data from ESP8266
  pinMode(4, OUTPUT);                           //BLUE pin is PB4                                                                                  PB4 BLUE      |              |     PB1   GREEN
  // Configure counter/timer0 for fast PWM on PB0 and PB1                                                                                GND                |_______|     PB0  RED
  TCCR0A = 3<<COM0A0 | 3<<COM0B0 | 3<<WGM00;
  TCCR0B = 0<<WGM02 | 3<<CS00; // Optional; already set
  // Configure counter/timer1 for fast PWM on PB4
  GTCCR = 1<<PWM1B | 3<<COM1B0;
  TCCR1 = 3<<COM1A0 | 7<<CS10;

  serial.begin(9600);
//  TCCR0B = TCCR0B & 0b11111000 | 0b001;
}

// Sets colour Red=0 Green=1 Blue=2 to specified intensity 0 (off) to 255 (max)
void SetColour (int colour, int intensity) 
{
  *Port[colour] = 255 - intensity;
}

void loop() 
{
      data_receive();
      update_color();
}

void data_receive() 
{
    while( serial.available() )
    {
        inbound.parse( serial.read(), massageReceived );
    } 
}

void update_color()
{
//    analogWrite( RPin, R );
//    analogWrite( GPin, G );
//    analogWrite( BPin, B );
    SetColour( 0, R );
    SetColour( 1, G );
    SetColour( 2, B );
}

void massageReceived()
{
    // CHECK IF THE MASSAGE'S ADDRESS MATCHES THE ONE FROM SENDER
    if( inbound.fullMatch( "RGB_VALUES" ) )
    {
        R = inbound.nextInt();
        G = inbound.nextInt();
        B = inbound.nextInt();

//        Serial.println(R);
//        Serial.println(G);
//        Serial.println(B);
//        Serial.println("OKK");
    }
}
