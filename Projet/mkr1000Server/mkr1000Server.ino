#include <SPI.h>
#include <WiFi101.h>

//char ssid[] = "public-epfl";
char ssid[] = "iPhone 6";
//char pass[] = "";
char pass[] = "bertedwin";
int status = WL_IDLE_STATUS;

WiFiServer server(80);

void setup(){
  Serial1.begin(9600);
  //Serial.begin(9600);
  pinMode(9,OUTPUT);
  while ( status != WL_CONNECTED) {
    //Serial.print("Attempting to connect to WiFi network.");
    status = WiFi.begin(ssid, pass);
    //delay(10000);
  }
 server.begin();
 digitalWrite(9, HIGH);
 delay(500);
 //digitalWrite(9, LOW);
 printWiFiStatus();
}
String buf;

void loop(){
    WiFiClient client = server.available(); 
    if(client){
        digitalWrite(9, LOW);
        String currentLine = "";        
      while (client.connected()) {            
        if (client.available()) {
          //client.println("hello");
          //delay(1000);          
          buf = Serial1.readString();
          //buf = Serial.readString();
          //buf = "value";
          //if (buf == "\n") {                 
            if (currentLine.length() == 0){
              client.println("HTTP/1.1 200 OK");
              client.println("Content-type:text/html");
              client.println();
              client.println("<!DOCTYPE html>");
              client.println("<html>");
              client.println("<body>");
              //client.println("<h1>Edwin je t'aime</h1>");
              client.println("<h1>E+J = coeur</hl>");
              client.print(buf);
              client.println("</body>");
              client.println("</html>");
              client.println();
              break;
              }
              else {
              currentLine = "";
            }
          //}
          //else if (buf != "\r") {   
          //  currentLine += buf;    
          //}
        }
      }
      client.stop();
  }
}

void printWiFiStatus() {
 
  // print your WiFi shield's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.print(rssi);
  Serial.println(" dBm");
}
