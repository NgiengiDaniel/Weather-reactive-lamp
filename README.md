# Weather-reactive-lamp
ESP8266 based lamp whose color can be manually set, and automatically depending on the local weather.

This project uses the esp-01 board to receive data packets from mobile phone or from a computer to control the color of the lamp.
These commands are sent to the Attiny85 chip to generate 3 PWM signals to control the RGB LEDs.

## How it works
1. When moving the sliders left or right, integer values from 0 to 255 are generated.
2. Using the oscP5 and the netP5 libraries in Processing, these integer values are combined in an organized packet and are sent to the IP address of the ESP.
3. The ESP receives this message and extracts the integer values, then sends it to the Attiny85, using the MSlipMassagePacker library.
4. Attiny85 receives the message and unpacks it using SlipMassageParser.
5. PWM signals are generated.

## Circuit
