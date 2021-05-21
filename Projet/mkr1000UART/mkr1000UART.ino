int data;
void setup(){
  Serial1.begin(9600);
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
  if(Serial1.available()){
    buf = Serial1.readString();
    digitalWrite(9, HIGH);
    delay(500);
    digitalWrite(9, LOW);
    delay(500);
    Serial.print(buf);
    Serial.println(state);
   
  }
}
