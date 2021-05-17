int data;
void setup(){
  Serial.begin(9600);
  pinMode(9,OUTPUT);

  digitalWrite(9, HIGH);
  delay(500);
  digitalWrite(9, LOW);
  delay(500);
  digitalWrite(9, HIGH);
  delay(500);
  digitalWrite(9, LOW);
  delay(500); 
}
String buf;
bool state = false;

void loop(){
  if(Serial.available()){
    buf = Serial.readString();
    Serial.print(buf);
    Serial.println(state);
   
  }
}
