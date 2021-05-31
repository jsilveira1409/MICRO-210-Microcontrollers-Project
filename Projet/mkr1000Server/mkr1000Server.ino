#include <SPI.h>
#include <WiFi101.h>

char ssid[] = "Martin Router King";
char pass[] = "legrandinquisiteur";

int status = WL_IDLE_STATUS;
WiFiServer server(80);


void setup(){
  Serial.begin(9600);
  while ( status != WL_CONNECTED) {
    status = WiFi.begin(ssid, pass);
    delay(2000);
  }
 server.begin();
}
byte received = 0;
byte data[180] = {0};
byte rec[180] = {0};

void loop() {
  
  if(Serial1.available()){
          for(int i(0); i<180; i++){
            received = Serial1.readBytes((char *)data, 1);           
            rec[i] = received;
          }
          WiFiClient client = server.available();   // listen for incoming clients
        
    if (client) {                             // if you get a client,
      while (client.connected()) {            // loop while the client's connected
          
          client.println("HTTP/1.1 200 OK");
          client.println("Content-type:text/html");
          client.println();
          for(int i(0); i<180; i++){
            client.println(rec[i]);
          }
          client.println();
          break;
    }
      client.stop();
    }
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
