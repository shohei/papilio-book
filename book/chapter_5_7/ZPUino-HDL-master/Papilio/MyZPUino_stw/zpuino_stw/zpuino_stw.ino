//*****************************************************************************
// File Name            : zpuino_stw.ino
//-----------------------------------------------------------------------------
// Function             : zpuino stop watch
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10 
//*****************************************************************************
#include <SevenSegHW.h>
#include "VGA.h"
#define UREGBASE IO_SLOT(13)
#define UREG0 REGISTER(UREGBASE,0);
#define UREG1 REGISTER(UREGBASE,1);
SEVENSEGHW sevenseg;
int textarea = 20;
int colors[] = {RED,GREEN,BLUE,YELLOW,PURPLE,CYAN,WHITE,BLACK};

#define sw_0  31
#define sw_1  29
#define sw_2  30

int vga_num (int x_p, int y_p, int data){
  VGA.printchar(x_p,y_p,((data&0xf)+0x30));
  return (data>>4) ;
}


void setup() {
  //入力ピン指定  
  pinMode(sw_0, INPUT);          
  pinMode(sw_1, INPUT);          
  pinMode(sw_2, INPUT);  
  //7セグメントLED表示スロット指定
  sevenseg.begin(12);
  //シリアル通信　ボーレート設置  
  Serial.begin(9600);  
  //VGA表示回路設定
  VGA.begin(VGAWISHBONESLOT(9),CHARMAPWISHBONESLOT(10));
  //VGA初期画面表示  
  VGA.clear();
  VGA.setBackgroundColor(BLACK);
  VGA.setColor(GREEN);
  VGA.printtext(25,0,"Papilio/ZPUino");
  VGA.printtext(25,10,"StopWatch");
}
// the loop routine runs over and over again forever:
void loop() {
  int lp;
  int sw_0_d1,sw_0_d2;
  int sw_1_d1,sw_1_d2;
  int sw_2_d1,sw_2_d2;
  int data;
  //ユザーレジスタのポインタ
  volatile unsigned int *ureg_0 = &UREG0;
  volatile unsigned int *ureg_1 = &UREG1;
  while(1){
      //測定値読み込み
      data = *ureg_1;
      //sw_0の読み込み
      sw_0_d1 = digitalRead(sw_0); 
      //sw_0が変化した場合    
      if(sw_0_d2!=sw_0_d1)
        //押された
        if(sw_0_d1==0){ 
          //シリアル通信　送信  
          Serial.println("start_stop");
          Serial.println(data,HEX);   
          //VGA表示
          VGA.printtext(25,20,"Start_stop");
        }
        //離した
        else
          //VGA表示 "Start_stop"の消去
           VGA.printtext(25,20,"          ");
      //sw_0の値　保存
      sw_0_d2=sw_0_d1;
      //sw_1の読み込み
      sw_1_d1 = digitalRead(sw_1); 
      //sw_1が変化した場合   
      if(sw_1_d2!=sw_1_d1)
        //押された
        if(sw_1_d1==0){
          //シリアル通信　送信  
           Serial.println("clear");
          //VGA表示
           Serial.println(*ureg_1,HEX);   
           VGA.printtext(25,20,"clear     ");
           }
         else
           VGA.printtext(25,20,"          ");
      //sw_1の値　保存
      sw_1_d2=sw_1_d1;
      //sw_2の読み込み
      sw_2_d1 = digitalRead(sw_2); 
      //sw_2が変化した場合   
      if(sw_2_d2!=sw_2_d1)
        //押された
        if(sw_2_d1==0){
          //シリアル通信　送信  
          Serial.println("rstb");
          Serial.println(*ureg_1,HEX);  
          //VGA表示 
          VGA.printtext(25,20,"rstb     ");
          }
        else
          VGA.printtext(25,20,"          ");
      //sw_2の値　保存
      sw_2_d2=sw_2_d1;
      //ここからは毎回の表示
      //7セグメントLED表示
      sevenseg.setHexValue(data);
      //sw_0,sw_1,sw_2の状態をLED表示
      *ureg_0 = (sw_2_d1 * 4) +(sw_1_d1 *2) + sw_0_d1;
      //VG表示
      data =vga_num(70,35,data);//10ms
      data =vga_num(60,35,data);//100ms
      VGA.printchar(50,35,'.'); //小数点
      data =vga_num(40,35,data);//1s
      data =vga_num(30,35,data);//10s
  }    
}
