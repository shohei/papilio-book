//*****************************************************************************
// File Name            : i2c_tmp102.ino
//-----------------------------------------------------------------------------
// Function             : zpuino i2c tmp102
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10 
//*****************************************************************************
#define I2CBASE IO_SLOT(8)
#define I2C_PRERL REGISTER(I2CBASE,0);
#define I2C_PRERH REGISTER(I2CBASE,1);
#define I2C_CTR REGISTER(I2CBASE,2);
#define I2C_TXR REGISTER(I2CBASE,3);
#define I2C_RXR REGISTER(I2CBASE,3);
#define I2C_CR REGISTER(I2CBASE,4);
#define I2C_CS REGISTER(I2CBASE,4);

#include <SevenSegHW.h>

SEVENSEGHW sevenseg;

// the setup routine runs once when you press reset:
void setup() {        
  volatile unsigned int *prerl_reg = &I2C_PRERL; 
  volatile unsigned int *prerh_reg = &I2C_PRERH;    
  volatile unsigned int *ctr_reg = &I2C_CTR;        
  // initialize the digital pin as an output.
  sevenseg.begin(12);
  Serial.begin(9600);  
  //I2Cのクロック周波数設定
  *prerl_reg = 0x20;  
  *prerh_reg = 0x20;
  *ctr_reg = 0x80;
  Serial.println(*prerl_reg,HEX);  
  Serial.println(*prerh_reg,HEX);  
  Serial.println(*ctr_reg,HEX);  
  delay(200);      // wait for a second
}

// the loop routine runs over and over again forever:
void loop() {  
  int data;
  int data_s;
  int data_h;
  volatile unsigned int *txr_reg = &I2C_TXR; 
  volatile unsigned int *cr_reg = &I2C_CR;  
  //txr slv_adr=1001000,wr=1(read)
   *txr_reg = 0x91;
  //start,rd
   *cr_reg = 0x90;   
  delay(10);      // wait
  //data=ff
   *txr_reg = 0xff;
  //start,rd
  delay(1);      // wait
   *cr_reg = 0x20;   
  delay(10);     // wait
  //温度の整数部を読み出し
  data = *txr_reg;
  //7セグメントLED用整数部分を4桁表示するため100倍して保存
  data_s = data*10;
  //シリアル送信　整数部
  Serial.print(data,DEC); 
  //シリアル送信　少数点 
  Serial.print(".");  
  //data=ff
   *txr_reg = 0xff;
  //stop,rd,nack
  delay(1);  
   *cr_reg = 0x68;  
  delay(10);  
  //少数点以下の温度を読み出して
  //小数点以下1位を整数へ変換
  data =  ((*txr_reg + 0x8)*10)/256;
  
  //if(data<10) //0.01-0.09の範囲は小数点のあとに0を付ける
  //  Serial.print("0");  
  Serial.println(data,DEC);
  //7セグメントLED用にデータに少数点以下を加算
  data_s = data_s + data;
  //7セグメントLEDに表示
  sevenseg.setIntValue(data_s,3);
  delay(  500);  
}
