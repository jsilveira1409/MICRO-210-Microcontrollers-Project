char data;
bool state = true;

void setup(){
  Serial1.begin(9600);
  pinMode(9,OUTPUT);

  digitalWrite(9, HIGH);
  delay(1000);
  digitalWrite(9, LOW);
  
}

void loop(){
  if (Serial1.available()>0) {
      data=Serial1.read();
      state !=state;
      delay(300);
  }
  digitalWrite(9, state);
}
