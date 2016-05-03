//*****************************************************************************
// File Name            : saikoro_vga.ino
//-----------------------------------------------------------------------------
// Function             : saikoro + VGA
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10 
//*****************************************************************************
#include "VGA.h"
int textarea = 20;
int colors[] = {RED,GREEN,BLUE,YELLOW,PURPLE,CYAN,WHITE,BLACK};

// LEDのピン番号定義
#define led_a 41
#define led_b 42
#define led_c 43
#define led_d 44
#define led_e 45
#define led_f 46
#define led_g 47
// プッシュスイッチのピン番号定義
#define sw_a 31
// 7セグのピン番号定義
#define seg_a 7
#define seg_b 10
#define seg_c 5
#define seg_d 6
#define seg_e 3
#define seg_f 4
#define seg_g 9
#define seg0_com 11

//サイコロのLED表示制御
void saikoro_led (char data_in) {            
  switch(data_in){
    case 0:
      digitalWrite(led_a, LOW);   
      digitalWrite(led_b, LOW);   
      digitalWrite(led_c, LOW);   
      digitalWrite(led_d, LOW);   
      digitalWrite(led_e, LOW);   
      digitalWrite(led_f, LOW);   
      digitalWrite(led_g, LOW);   
      break;
    case 1:
      digitalWrite(led_a, LOW);   
      digitalWrite(led_b, LOW);   
      digitalWrite(led_c, LOW);   
      digitalWrite(led_d, HIGH);   
      digitalWrite(led_e, LOW);   
      digitalWrite(led_f, LOW);   
      digitalWrite(led_g, LOW);   
      break;
    case 2:
      digitalWrite(led_a, LOW);   
      digitalWrite(led_b, LOW);   
      digitalWrite(led_c, HIGH);   
      digitalWrite(led_d, LOW);   
      digitalWrite(led_e, HIGH);   
      digitalWrite(led_f, LOW);   
      digitalWrite(led_g, LOW);   
      break;
    case 3:
      digitalWrite(led_a, LOW);   
      digitalWrite(led_b, LOW);   
      digitalWrite(led_c, HIGH);   
      digitalWrite(led_d, HIGH);   
      digitalWrite(led_e, HIGH);   
      digitalWrite(led_f, LOW);   
      digitalWrite(led_g, LOW);   
      break;
    case 4:
      digitalWrite(led_a, LOW);   
      digitalWrite(led_b, HIGH);   
      digitalWrite(led_c, HIGH);   
      digitalWrite(led_d, LOW);   
      digitalWrite(led_e, HIGH);   
      digitalWrite(led_f, HIGH);   
      digitalWrite(led_g, LOW);   
      break;
    case 5:
      digitalWrite(led_a, LOW);   
      digitalWrite(led_b, HIGH);   
      digitalWrite(led_c, HIGH);   
      digitalWrite(led_d, HIGH);   
      digitalWrite(led_e, HIGH);   
      digitalWrite(led_f, HIGH);   
      digitalWrite(led_g, LOW);  
      break;
    case 6:
      digitalWrite(led_a, HIGH);   
      digitalWrite(led_b, HIGH);   
      digitalWrite(led_c, HIGH);   
      digitalWrite(led_d, LOW);   
      digitalWrite(led_e, HIGH);   
      digitalWrite(led_f, HIGH);   
      digitalWrite(led_g, HIGH);  
      break;
    case 7:
      digitalWrite(led_a, HIGH);   
      digitalWrite(led_b, HIGH);   
      digitalWrite(led_c, HIGH);   
      digitalWrite(led_d, HIGH);   
      digitalWrite(led_e, HIGH);   
      digitalWrite(led_f, HIGH);   
      digitalWrite(led_g, HIGH);  
      break;
    default:
      break;
  }
}

//サイコロの7セグLED表示制御
void saikoro_7seg (char data_in) {     
  switch(data_in){
    case 0:
      /*
      digitalWrite(seg_a, LOW);   
      digitalWrite(seg_b, LOW);   
      digitalWrite(seg_c, LOW);   
      digitalWrite(seg_d, LOW);   
      digitalWrite(seg_e, LOW);   
      digitalWrite(seg_f, LOW);   
      digitalWrite(seg_g, HIGH);   
      */
      digitalWrite(seg_a, HIGH);   
      digitalWrite(seg_b, HIGH);   
      digitalWrite(seg_c, HIGH);   
      digitalWrite(seg_d, HIGH);   
      digitalWrite(seg_e, HIGH);   
      digitalWrite(seg_f, HIGH);   
      digitalWrite(seg_g, HIGH);   
      break;
    case 1:
      digitalWrite(seg_a, HIGH);   
      digitalWrite(seg_b, LOW);   
      digitalWrite(seg_c, LOW);   
      digitalWrite(seg_d, HIGH);   
      digitalWrite(seg_e, HIGH);   
      digitalWrite(seg_f, HIGH);   
      digitalWrite(seg_g, HIGH);   
      break;
    case 2:
      digitalWrite(seg_a, LOW);   
      digitalWrite(seg_b, LOW);   
      digitalWrite(seg_c, HIGH);   
      digitalWrite(seg_d, LOW);   
      digitalWrite(seg_e, LOW);   
      digitalWrite(seg_f, HIGH);   
      digitalWrite(seg_g, LOW);   
      break;
    case 3:
      digitalWrite(seg_a, LOW);   
      digitalWrite(seg_b, LOW);   
      digitalWrite(seg_c, LOW);   
      digitalWrite(seg_d, LOW);   
      digitalWrite(seg_e, HIGH);   
      digitalWrite(seg_f, HIGH);   
      digitalWrite(seg_g, LOW);   
      break;
    case 4:
      digitalWrite(seg_a, HIGH);   
      digitalWrite(seg_b, LOW);   
      digitalWrite(seg_c, LOW);   
      digitalWrite(seg_d, HIGH);   
      digitalWrite(seg_e, HIGH);   
      digitalWrite(seg_f, LOW);   
      digitalWrite(seg_g, LOW);   
      break;
    case 5:
      digitalWrite(seg_a, LOW);   
      digitalWrite(seg_b, HIGH);   
      digitalWrite(seg_c, LOW);   
      digitalWrite(seg_d, LOW);   
      digitalWrite(seg_e, HIGH);   
      digitalWrite(seg_f, LOW);   
      digitalWrite(seg_g, LOW);  
      break;
    case 6:
      digitalWrite(seg_a, LOW);   
      digitalWrite(seg_b, HIGH);   
      digitalWrite(seg_c, LOW);   
      digitalWrite(seg_d, LOW);   
      digitalWrite(seg_e, LOW);   
      digitalWrite(seg_f, LOW);   
      digitalWrite(seg_g, LOW);  
      break;
    case 7:
      digitalWrite(seg_a, LOW);   
      digitalWrite(seg_b, LOW);   
      digitalWrite(seg_c, LOW);   
      digitalWrite(seg_d, HIGH);   
      digitalWrite(seg_e, HIGH);   
      digitalWrite(seg_f, HIGH);   
      digitalWrite(seg_g, HIGH);  
      break;
    default:
      break;
  }
  digitalWrite(seg0_com, LOW);     
}

//サイコロのVGA表示制御
void saikoro_vga (char data_in) {     
  switch(data_in){
    case 0:
      VGA.printtext(25,30," ");
      VGA.printtext(25,50," ");
      VGA.printtext(25,70," ");
      VGA.printtext(45,50," ");
      VGA.printtext(65,30," ");
      VGA.printtext(65,50," ");
      VGA.printtext(65,70," ");
      break;
    case 1:
      VGA.printtext(25,30," ");
      VGA.printtext(25,50," ");
      VGA.printtext(25,70," ");
      VGA.printtext(45,50,"X");
      VGA.printtext(65,30," ");
      VGA.printtext(65,50," ");
      VGA.printtext(65,70," ");
      break;
    case 2:
      VGA.printtext(25,30,"X");
      VGA.printtext(25,50," ");
      VGA.printtext(25,70," ");
      VGA.printtext(45,50," ");
      VGA.printtext(65,30," ");
      VGA.printtext(65,50," ");
      VGA.printtext(65,70,"X");
      break;
    case 3:
      VGA.printtext(25,30,"X");
      VGA.printtext(25,50," ");
      VGA.printtext(25,70," ");
      VGA.printtext(45,50,"X");
      VGA.printtext(65,30," ");
      VGA.printtext(65,50," ");
      VGA.printtext(65,70,"X");
      break;
    case 4:
      VGA.printtext(25,30,"X");
      VGA.printtext(25,50," ");
      VGA.printtext(25,70,"X");
      VGA.printtext(45,50," ");
      VGA.printtext(65,30,"X");
      VGA.printtext(65,50," ");
      VGA.printtext(65,70,"X");
      break;
    case 5:
      VGA.printtext(25,30,"X");
      VGA.printtext(25,50," ");
      VGA.printtext(25,70,"X");
      VGA.printtext(45,50,"X");
      VGA.printtext(65,30,"X");
      VGA.printtext(65,50," ");
      VGA.printtext(65,70,"X");
      break;
    case 6:
      VGA.printtext(25,30,"X");
      VGA.printtext(25,50,"X");
      VGA.printtext(25,70,"X");
      VGA.printtext(45,50," ");
      VGA.printtext(65,30,"X");
      VGA.printtext(65,50,"X");
      VGA.printtext(65,70,"X");
      break;
    default:
      break;
  }
}
    
void saikoro_disp (char data_in) {    
   saikoro_led(data_in);
   saikoro_7seg(data_in);
   saikoro_vga(data_in);
}

// the setup routine runs once when you press reset:
void setup() {  
  // initialize the digital pin as an output.
  pinMode(led_a, OUTPUT);     
  pinMode(led_b, OUTPUT);     
  pinMode(led_c, OUTPUT);     
  pinMode(led_d, OUTPUT);     
  pinMode(led_e, OUTPUT);     
  pinMode(led_f, OUTPUT);     
  pinMode(led_g, OUTPUT);     
  pinMode(sw_a, INPUT);    
  pinMode(seg_a, OUTPUT);     
  pinMode(seg_b, OUTPUT);     
  pinMode(seg_c, OUTPUT);     
  pinMode(seg_d, OUTPUT);     
  pinMode(seg_e, OUTPUT);     
  pinMode(seg_f, OUTPUT);     
  pinMode(seg_g, OUTPUT);       
  pinMode(seg0_com, OUTPUT);   
  Serial.begin(9600);           
  VGA.begin(VGAWISHBONESLOT(9),CHARMAPWISHBONESLOT(10));  
  VGA.clear();
  VGA.setBackgroundColor(BLACK);
  VGA.setColor(GREEN);
  VGA.printtext(25,0,"Papilio/ZPUino");
  VGA.printtext(25,10,"Saikoro");
}
// the loop routine runs over and over again forever:
void loop() {
  int chg_tim; //数字決定時の表示時間
  char s_en=0; //サイコロの動作イネーブル 1で動作
  int num=0;   //サイコロの数字
  //while文でループして初期化されないようにする
  while(1){ 
  //スイッチが0(押された状態)では番号を高速でカウント
  if((digitalRead(sw_a)==0)){
    //Start表示
     if(s_en==0){
       Serial.println("start");
       VGA.printtext(25,20,"Start");
     }
    //イネーブルにする
     s_en=1;
    //サイコロのカウント
    if(num>=6) //6以上ならば
      num=1; //１にする
    else
      num++; //+1する
    saikoro_disp(num);//サイコロ表示
    delay(10);//遅延
  }
  else
  //スイッチが1(押してない状態)の場合
    //サイコロが停止するまでイネーブルになっている
    if(s_en==1){
      //表示時間を長くしながらループ
      for( chg_tim=0; chg_tim<=8;chg_tim++){
        //サイコロのカウント
        if(num>=6)
          num=1;
        else
          num++;
        saikoro_disp(num);//サイコロ表示
        delay(100 + chg_tim*100);//遅延
      }
      Serial.println("stop");   
      Serial.println(num);  
      VGA.printtext(25,20,"Stop "); 
      s_en=0;//遅延させた表示が終了したらイネーブルを解除
      //数字が決定したので3回点滅
      for( chg_tim=0; chg_tim<=2;chg_tim++){
        saikoro_disp(0);
        delay(150);
        saikoro_disp(num);
        delay(150);
      }
    }
    //イネーブルでない場合は数字を表示
    else{
      saikoro_disp(num);
    }
  }
}
