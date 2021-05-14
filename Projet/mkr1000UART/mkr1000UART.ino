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
byte buf = 0;
void loop(){
  if(Serial.available()){
  buf = Serial.read();
  }else{
    buf = 0;
  }
  Serial.println(buf, DEC);
  if(buf == 149){
    digitalWrite(9, HIGH);
  }
  delay(1000);
}
