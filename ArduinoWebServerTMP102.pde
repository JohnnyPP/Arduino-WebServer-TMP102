#include <WiFly.h>
#include <Wire.h>
#include "Credentials.h"

// Initialize the Ethernet server library
// with the IP address and port you want to use
// (port 80 is default for HTTP):
Server server(80);


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
  Serial.print("IP: ");
  Serial.println(WiFly.ip());
  
  server.begin();
}

void loop() 
{
  ///////////////////TMP102
  
  float fCelsius = getTemperature();
  char strCelsius[7];
  dtostrf(fCelsius,3,3,strCelsius);
  String strSendTemperature = String(strCelsius);
  Serial.println(strSendTemperature);
  delay(500);

  //////////////////////////

  
  Client client = server.available();
  if (client) 
  {
	// an http request ends with a blank line
	
	Serial.println("New client");
	
	boolean current_line_is_blank = true;
	while (client.connected()) 
	{
	  if (client.available()) 
	  {
		char c = client.read();
		// if we've gotten to the end of the line (received a newline
		// character) and the line is blank, the http request has ended,
		// so we can send a reply
		if (c == '\n' && current_line_is_blank) 
		{
		  // send a standard http response header
		  client.println("HTTP/1.1 200 OK");
		  client.println("Content-Type: text/html");
		  client.println();
		  
		  client.print("TMP102 sensor temperature");
		 
		  client.print(" is ");
		  client.print(strSendTemperature);
		  client.println("<br />");
		  
		  break;
		}
		if (c == '\n') {
		  // we're starting a new line
		  current_line_is_blank = true;
		} else if (c != '\r') {
		  // we've gotten a character on the current line
		  current_line_is_blank = false;
		}
	  }
	}
	// give the web browser time to receive the data
	delay(100);
	client.stop();
	Serial.println("Client disonnected");
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