//*****************************************************************************
// File Name            : led_matrix_dynamic.ino
//-----------------------------------------------------------------------------
// Function             : led_matrix_dynamic
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10 
//*****************************************************************************
unsigned char row_set(unsigned char row_in){
  if (row_in>7)
    return row_in - 8 ;
  else
    return row_in ;
}

void setup() {
  int i;  
  for(i=0;i<=31;i++){
    pinMode(i, OUTPUT);
  }
}

void loop() {
  unsigned int lp_1,lp_2,lp_3;
  unsigned int row,col;
  //表示パタン原型
  /*
  unsigned  char r_d[8]={0xC1,0x83,0x07,0x0e,0x1c,0x38,0x70,0xe0};
  unsigned  char g_d[8]={0x78,0xf0,0xe1,0xc3,0x87,0x0f,0x1e,0x3c};
  unsigned  char b_d[8]={0x0f,0x1e,0x3c,0x78,0xf0,0xe1,0xc3,0x87};
  */
  /*
  unsigned  char r_d[8]={0xe0,0x70,0x38,0x1c,0x1c,0x38,0x70,0xe0};
  unsigned  char g_d[8]={0x87,0xc3,0xe1,0xf0,0xf0,0xe1,0xc3,0x87};
  unsigned  char b_d[8]={0x3C,0x1e,0x0f,0x87,0x87,0x0f,0x1e,0x3c};
  */
  unsigned  char r_d[8]={0x00,0x18,0x3c,0x7e,0x7e,0x3c,0x18,0x00};
  unsigned  char g_d[8]={0x3c,0x7e,0xe7,0xc3,0xc3,0xe7,0x7e,0x3c};
  unsigned  char b_d[8]={0xe7,0xc3,0x81,0x00,0x00,0x81,0xc3,0xe7};
  //表示パタン
  unsigned  char led_r[8];
  unsigned  char led_g[8];
  unsigned  char led_b[8];  
  for(lp_1=0;lp_1<8;lp_1++){ 
    //ROW方向にずらした表示パタンをレジスタ書き込み
    for(lp_2=0;lp_2<8;lp_2++){ 
      led_r[lp_2]=r_d[row_set(lp_2+lp_1)];
      led_g[lp_2]=g_d[row_set(lp_2+lp_1)];
      led_b[lp_2]=b_d[row_set(lp_2+lp_1)];
    }         
    //for(lp_3=0;lp_3<1000;lp_3++){ 
    for(lp_3=0;lp_3<10;lp_3++){ 
      //ダイナミック点灯制御
      for(row=0;row<8;row++){
        digitalWrite(row, HIGH);  //アノードコモンをHi
        for (col=0;col<=7;col++){ //列の移動
          digitalWrite((8+col), (led_r[row]>>col)&0x1);//シンクドライバーをON    
          digitalWrite((16+col),(led_g[row]>>col)&0x1);//シンクドライバーをON    
          digitalWrite((24+col),(led_b[row]>>col)&0x1);//シンクドライバーをON  
        } 
        delay(2);  //遅延  
        for (col=0;col<8;col++){ //列の移動
          digitalWrite((8+col),0x0);//シンクドライバーをOFF 
          digitalWrite((16+col),0x0);//シンクドライバーをOFF    
          digitalWrite((24+col),0x0);//シンクドライバーをOFF  
        }   
        digitalWrite(row, LOW);  //アノードコモンをHi   
      }
    }
  }
}

