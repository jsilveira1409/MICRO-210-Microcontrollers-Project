#include <SPI.h>
#include <WiFi101.h>

char ssid[] = "public-epfl";
char pass[] = "";
int status = WL_IDLE_STATUS;

WiFiServer server(80);

void setup(){
  Serial1.begin(9600);
  pinMode(9,OUTPUT);
  while ( status != WL_CONNECTED) {
    status = WiFi.begin(ssid, pass);
    delay(10000);
  }
 server.begin();
 digitalWrite(9, HIGH);
}
String buf;

void loop(){
    WiFiClient client = server.available(); 
    if(client){
        digitalWrite(9, LOW);
        String currentLine = "";        
      while (client.connected()) {            
        if (client.available()) {             
          buf = Serial1.readString();
          if (buf == "\n") {                 
            if (currentLine.length() == 0){
              client.println("HTTP/1.1 200 OK");
              client.println("Content-type:text/html");
              client.println();
              client.print("<!DOCTYPE html>");
              client.print("<html>");
              client.print("<body>");
              client.print("<h1>Edwin je t'aime</h1>");
              client.print(buf);
              client.print("</body>");
              client.print("</html>");
              client.println();
              break;
            }else {
              currentLine = "";
            }
          }
          else if (buf != "\r") {   
            currentLine += buf;    
          }
        }
      }
      client.stop();
  }
}
