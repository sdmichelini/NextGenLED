The MIT License (MIT)

Copyright (c) 2014 sdmichelini

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

// This #include statement was automatically added by the Spark IDE.
#include "neopixel/neopixel.h"



//Bit-Masks for Colors
#define G 0xFF0000
#define R 0xFF00
#define B 0xFF
//Bit Mask for Command
#define CODE 0xF000000
//Command Codes
#define SOLID 1
#define FADE 2
#define RAINBOW 3
#define AUTO 4
#define SET_DAY_COLOR 5
#define SET_NIGHT_COLOR 6

///Auto Variables
#define NIGHT_HOUR 18
#define WAKE_HOUR 9

#define DAY_COLOR 0xFFF08F
#define NIGHT_COLOR 0xFF8800

//Color during the daytime
uint32_t dayColor;
//Color during the nighttime
uint32_t nightColor;

// IMPORTANT: Set pixel COUNT, PIN and TYPE
#define PIXEL_PIN A5
#define PIXEL_COUNT 59
#define PIXEL_TYPE WS2812

//Solid Red-Color
#define DEFAULT_COMMAND 0x1FF0000

//Fade time in loops
#define FADE_LOOPS 255
uint32_t loopCount;

unsigned int currentCommand;
unsigned int lastCommand;

Adafruit_NeoPixel strip = Adafruit_NeoPixel(PIXEL_COUNT, PIXEL_PIN, PIXEL_TYPE);

int changeStrip(String args);

void handleCommand(unsigned int command);

TCPServer server = TCPServer(36501);
TCPClient client;

String myTime = "W09:00S18:00";

///Packet Size in Bytes
uint8_t PACKET_SIZE=4;
///State Variables for Auto Command Handled in handleCommand
bool lastDay,lastNight;

SYSTEM_MODE(SEMI_AUTOMATIC);

void setup() {
    Spark.connect();
    server.begin();
    Spark.function("change", changeStrip);
    Spark.variable("command",&currentCommand,INT);
    strip.begin();
    strip.show();
    currentCommand = DEFAULT_COMMAND;
    lastCommand = 0;
    loopCount = 0;
    Time.zone(-5);
    lastDay = true;
    lastNight = true;
    dayColor = DAY_COLOR;
    nightColor = NIGHT_COLOR;
}

void loop() {
    if(loopCount+1>FADE_LOOPS)
    {
        loopCount=0;
    }
    else
    {
        loopCount++;
    }
    if (client.connected()) 
    {
        if(client.available()>=PACKET_SIZE)
        {
            char readBuf[4];
            readBuf[0] = client.read();
            readBuf[1] = client.read();
            readBuf[2] = client.read();
            readBuf[3] = client.read();
            client.flush();
            memcpy(&currentCommand,readBuf,PACKET_SIZE);
            currentCommand = ntohl(currentCommand);
            lastDay = true;
            lastNight = true;
        }
    } 
    else 
    {
        // if no client is yet connected, check for a new connection
        client = server.available();
    }
    
    handleCommand(currentCommand);
    delay(30);
}

int changeStrip(String args)
{
    uint32_t newCommand;
    newCommand=(strtoul(args.c_str(),NULL,16));
    unsigned int commandType = (newCommand&CODE)>>24;
    if(commandType == SET_DAY_COLOR)
    {
        dayColor = newCommand & 0xFFFFFF;
    }
    else if(commandType == SET_NIGHT_COLOR)
    {
        nightColor = newCommand & 0xFFFFFF;
    }
    else
    {
        currentCommand = newCommand;
    }
    lastDay = true;
    lastNight = true;
    return 0;
}

///Format for args should be W06:30S18:00
int setTime(String args)
{
    //First find wake up time
    int wakePos = args.indexOf("W");
    int sleepPos = args.indexOf("S");
    //Hour
    int wakeHour = 0;
    int wakeMinute = 0;
    int sleepHour = 0;
    int sleepMinute = 0;
    if(wakePos!=-1)
    {
        wakeHour = args.substring(wakePos+1,2).toInt();
        wakeMinute = args.substring(wakePos+4,2).toInt();
    }
    if(sleepPos!=-1)
    {
        sleepHour = args.substring(sleepPos+1,2).toInt();
        sleepMinute = args.substring(sleepPos+4,2).toInt();
    }
    return 0;
}

// Input a value 0 to 255 to get a color value.
// The colours are a transition r - g - b - back to r.
uint32_t Wheel(byte WheelPos) {
  if(WheelPos < 85) {
   return strip.Color(WheelPos * 3, 255 - WheelPos * 3, 0);
  } else if(WheelPos < 170) {
   WheelPos -= 85;
   return strip.Color(255 - WheelPos * 3, 0, WheelPos * 3);
  } else {
   WheelPos -= 170;
   return strip.Color(0, WheelPos * 3, 255 - WheelPos * 3);
  }
}
/*!
@function handleCommand

Main state machine for the commands the drive the LED strip. Designed to call strip.show() as infrequently as possible. Extracts the color from the command and the type of command. Also
handles auto color. 

@param command
    Hex Unsigned int with the first four bytes being the command, and the next 24 being the 8 bit RGB colors.

*/
void handleCommand(unsigned int command)
{
    unsigned int commandType = (command&CODE)>>24;
    uint32_t color = command & 0xFFFFFF;
    if(commandType==SOLID)
    {
        if(lastCommand == currentCommand)
        {
            return;
        }
        for(unsigned int i = 0; i < PIXEL_COUNT; i++)
        {
            strip.setPixelColor(i,color);
        }
        strip.setBrightness(255);
        strip.show();
        lastCommand = currentCommand;
    }
    else if(commandType==FADE)
    {
        for(unsigned int i = 0; i < PIXEL_COUNT; i++)
        {
            strip.setPixelColor(i,color);
        }
        unsigned int count;
        if(loopCount>(FADE_LOOPS/2))
        {
            count = FADE_LOOPS - loopCount;
        }
        else
        {
            count = loopCount;
        }
        strip.setBrightness((255 * count * 2)/FADE_LOOPS);
        strip.show();
    }
    else if(commandType==RAINBOW)
    {
        for(uint8_t i=0; i<strip.numPixels(); i++) 
        {
            strip.setPixelColor(i, Wheel((i+((loopCount*FADE_LOOPS)/255)) & 255));
        }
        strip.show();
    }
    else if(commandType==AUTO)
    {
        
        ///Between 6 PM and Midnight
        if(lastNight && (Time.hour()>NIGHT_HOUR))
        {
            lastNight = false;
            lastDay = true;
            if(color==0x000000)
            {
                for(unsigned int i = 0; i < PIXEL_COUNT; i++)
                {
                    strip.setPixelColor(i,0x000000);
                }
            }
            else
            {
                for(unsigned int i = 0; i < PIXEL_COUNT; i++)
                {
                    strip.setPixelColor(i,nightColor);
                }
            }
            strip.setBrightness(255);
            strip.show();
        }
        else if(lastNight && (Time.hour()<WAKE_HOUR))
        {
            lastNight = false;
            lastDay = true;
            if(color==0x000000)
            {
                for(unsigned int i = 0; i < PIXEL_COUNT; i++)
                {
                    strip.setPixelColor(i,0x000000);
                }
            }
            else
            {
                for(unsigned int i = 0; i < PIXEL_COUNT; i++)
                {
                    strip.setPixelColor(i,nightColor);
                }
            }
            strip.setBrightness(255);
            strip.show();
        }
        else if(Time.hour()>WAKE_HOUR&&Time.hour()<NIGHT_HOUR)
        {
            if(lastDay)
            {
                lastNight = true;
                lastDay = false;
                for(unsigned int i = 0; i < PIXEL_COUNT; i++)
            {
                strip.setPixelColor(i,dayColor);
            }
            strip.setBrightness(255);
            strip.show();
            }
        }
        
       
        
    }
    
}
