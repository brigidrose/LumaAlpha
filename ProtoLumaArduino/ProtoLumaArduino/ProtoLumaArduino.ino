const int motorPin = 0; //pin 0 on bean

int incomingByte = 0;

void setup() {
  // put your setup code here, to run once:
  Serial.begin(57600);
  pinMode(motorPin, OUTPUT);
}

void loop() {
  // put your main code here, to run repeatedly
  
  if(Serial.available() > 0){
    incomingByte = Serial.read();
    Serial.print(incomingByte);
    if (incomingByte == 82){
      Serial.print("IT's R");
      digitalWrite(motorPin, HIGH);
    }
    else if (incomingByte == 71){
      Serial.print("IT's G");
      digitalWrite(motorPin, LOW);
    }
    else if (incomingByte == 66){
      Serial.print("IT's B");
    }
  }
  
}
