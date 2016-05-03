/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */
//int led = 13; 
int led = 49; //LEDのピン番号指定、PapilioProのLEDは49番

// the setup routine runs once when you press reset:
//セットアップ関数はリセット後に1回だけ実行されます。初期設定をここに書きます。
void setup() {
  // initialize the digital pin as an output.
  pinMode(led, OUTPUT); //led(49番ピン)を出力モードにする。
}

// the loop routine runs over and over again forever:
//loop関数はsetup関数の後に実行される。
//loop関数の終了後は再びloop関数が実行され、くり返し実行される。
void loop() {
  digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
                             //LED点灯
  delay(1000);               // wait for a second
                             //1秒の待ち
  digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
                             //LED消灯
  delay(1000);               // wait for a second
                             //1秒の待ち
}
