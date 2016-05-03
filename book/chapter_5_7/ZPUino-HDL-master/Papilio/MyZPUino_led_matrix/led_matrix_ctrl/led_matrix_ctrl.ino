//*****************************************************************************
// File Name            : led_matrix_ctrl.ino
//-----------------------------------------------------------------------------
// Function             : zpuino led matrix
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10 
//*****************************************************************************
#define LED_M_BASE IO_SLOT(9) //slot9のベースアドレス
#define LED_M_R0 REGISTER(LED_M_BASE,0);//r_data_0レジスタのアドレス
#define LED_M_R1 REGISTER(LED_M_BASE,1);//r_data_1レジスタのアドレス
#define LED_M_G0 REGISTER(LED_M_BASE,2);//g_data_0レジスタのアドレス
#define LED_M_G1 REGISTER(LED_M_BASE,3);//g_data_1レジスタのアドレス
#define LED_M_B0 REGISTER(LED_M_BASE,4);//b_data_0レジスタのアドレス
#define LED_M_B1 REGISTER(LED_M_BASE,5);//b_data_1レジスタのアドレス

unsigned char row_set(unsigned char row_in){
  if (row_in>7)
    return row_in - 8 ;
  else
    return row_in ;
}

void setup() {
}

void loop() {
  unsigned int lp_1,lp_2;
  volatile unsigned int *r_data_0 = &LED_M_R0; //r0レジスタのポインタ
  volatile unsigned int *r_data_1 = &LED_M_R1; //r1レジスタのポインタ
  volatile unsigned int *g_data_0 = &LED_M_G0; //g0レジスタのポインタ
  volatile unsigned int *g_data_1 = &LED_M_G1; //g1レジスタのポインタ
  volatile unsigned int *b_data_0 = &LED_M_B0; //b0レジスタのポインタ
  volatile unsigned int *b_data_1 = &LED_M_B1; //b1レジスタのポインタ
  //表示パタン
  unsigned  char r_d[8]={0x00,0x18,0x3c,0x7e,0x7e,0x3c,0x18,0x00};
  unsigned  char g_d[8]={0x3c,0x7e,0xe7,0xc3,0xc3,0xe7,0x7e,0x3c};
  unsigned  char b_d[8]={0xe7,0xc3,0x81,0x00,0x00,0x81,0xc3,0xe7};
  //表示パタン
  unsigned char led_r[8];
  unsigned char led_g[8];
  unsigned char led_b[8];
  for(lp_1=0;lp_1<8;lp_1++){ 
    //ROW方向にずらした表示パタンをレジスタ書き込み
    for(lp_2=0;lp_2<8;lp_2++){ 
      led_r[lp_2]=r_d[row_set(lp_2+lp_1)];
      led_g[lp_2]=g_d[row_set(lp_2+lp_1)];
      led_b[lp_2]=b_d[row_set(lp_2+lp_1)];
    }         
    //レジスタ書き込み
    *r_data_0 =(led_r[3]<<24)|(led_r[2]<<16)|(led_r[1]<<8)|led_r[0];
    *r_data_1 =(led_r[7]<<24)|(led_r[6]<<16)|(led_r[5]<<8)|led_r[4];
    *g_data_0 =(led_g[3]<<24)|(led_g[2]<<16)|(led_g[1]<<8)|led_g[0];
    *g_data_1 =(led_g[7]<<24)|(led_g[6]<<16)|(led_g[5]<<8)|led_g[4];
    *b_data_0 =(led_b[3]<<24)|(led_b[2]<<16)|(led_b[1]<<8)|led_b[0];
    *b_data_1 =(led_b[7]<<24)|(led_b[6]<<16)|(led_b[5]<<8)|led_b[4];
    delay(100);  //遅延
  }
 }
