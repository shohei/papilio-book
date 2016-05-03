//*****************************************************************************
// File Name            : led_matrix_test.ino
//-----------------------------------------------------------------------------
// Function             : led_matrix_test
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10 
//*****************************************************************************
void setup() {
  int i;
  for(i=0;i<=31;i++){
    pinMode(i, OUTPUT);
    digitalWrite(i, LOW); 
  }
}
void loop() {
  int rgb; //色指定 0:赤 1:緑 2:赤
  int row; //行指定
  int col; //列指定
  for(rgb=0;rgb<3;rgb++){ //色の変更
    for(row=0;row<=7;row++){ //行の移動
    digitalWrite(row, HIGH); //アノード・コモンをHigh
      for (col=0;col<=7;col++){ //列の移動
        digitalWrite(((rgb+1)*8+col),HIGH); //シンク・ドライバをON
        delay(250); // wait
        digitalWrite(((rgb+1)*8+col),LOW); //シンク・ドライバをOFF
      }
    digitalWrite(row, LOW); //アノード・コモンをLow
    }
  }
}
