#include <SPI.h>
#include <WiFi101.h>

char ssid[] = "Jojo";
char pass[] = "Smerdiakov";

int status = WL_IDLE_STATUS;
byte data[360];
WiFiServer server(80);
//IPAddress ip(192, 168, 0, 177);    


void setup(){
  Serial1.begin(9600);
  pinMode(9,OUTPUT);
  //WiFi.config(ip);
  while ( status != WL_CONNECTED) {
    status = WiFi.begin(ssid, pass);
    delay(10000);
  }
 server.begin();
 digitalWrite(9, HIGH);
 delay(500);
 for(int i(0); i<360; ++i){
  data[i] = 0;
 }
 digitalWrite(9, LOW);
 delay(500);
 
 digitalWrite(9, HIGH);
 delay(500);
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
            Serial1.readBytes(data,360);
            if (currentLine.length() == 0){
              client.println("HTTP/1.1 200 OK");
              client.println("Content-type:text/html");
              client.println();
              client.println("<!DOCTYPE html>");
              client.println("<html>");
              client.println("<body>");
              //client.println("<h1>Edwin je t'aime</h1>");
              client.println("<h1>E+J = coeur</hl>");
              for(int i(0); i<360; ++i)
                client.println(data[i]);
              client.println("</body>");
              client.println("</html>");
              client.println();
              break;
            }else {
              currentLine = "";
            }
        }
      }
      //client.stop();
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
