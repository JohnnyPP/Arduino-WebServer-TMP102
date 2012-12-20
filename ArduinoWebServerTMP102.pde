#include <WiFly.h>
#include <Wire.h>
#include "Credentials.h"

Server server(10000);					//port
int tmp102Address = 0x48;

void setup() 
{
  Wire.begin();
  WiFly.begin();

  if (!WiFly.join(ssid, passphrase))
  {
	while (1) 
	{
	  // Hang on failure.
	}
  }

  Serial.begin(9600);
  Serial.print("IP: ");					//IP: 192.168.2.101 - 192.168.2.104
  Serial.println(WiFly.ip());
  
  server.begin();
}

void loop() 
{

  Client client = server.available();

  if(client) 
  {
	Serial.println("Client connected");
	while (client.connected()) 
	{
	  char strCelsius[7];

	  dtostrf(getTemperature(),3,3,strCelsius);
	  String strSendTemperature = String(strCelsius);
	  Serial.println(strSendTemperature);
	  client.println(strSendTemperature);
	  delay(500);
	}
	client.stop();
	Serial.println("Client disconnected");
  }
}


float getTemperature()
{
  Wire.requestFrom(tmp102Address,2);

  byte MSB = Wire.read();
  byte LSB = Wire.read();

  //it's a 12bit int, using two's compliment for negative
  int TemperatureSum = ((MSB << 8) | LSB) >> 4;

  float celsius = TemperatureSum*0.0625;
  return celsius;
}