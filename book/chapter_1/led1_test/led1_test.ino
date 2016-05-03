#define LED_PIN 49

void setup() {
  pinMode(LED_PIN, OUTPUT);
}
void loop(){
  delay(200);
  digitalWrite(LED_PIN, HIGH); //点灯
  delay(200);
  digitalWrite(LED_PIN, LOW); //消灯
}
