//*****************************************************************************
// File Name            : camera_sd_ctrl.ino
//-----------------------------------------------------------------------------
// Function             : camera_sd_ctrl
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/101
//*****************************************************************************
//SDカード用ヘッダファイル
#include <SD.h>
//SD Card on RetroCade MegaWing
#define CSPIN  WING_C_13
#define SDIPIN WING_C_12
#define SCKPIN WING_C_11
#define SDOPIN WING_C_10
//I2Cマクロ定義
#define I2CBASE IO_SLOT(8)
#define I2C_PRERL REGISTER(I2CBASE,0);
#define I2C_PRERH REGISTER(I2CBASE,1);
#define I2C_CTR REGISTER(I2CBASE,2);
#define I2C_TXR REGISTER(I2CBASE,3);
#define I2C_RXR REGISTER(I2CBASE,3);
#define I2C_CR REGISTER(I2CBASE,4);
#define I2C_CS REGISTER(I2CBASE,4);
//cameraコントローラ・マクロ定義(OV7670)
#define VRAM_BASE IO_SLOT(9)
#define VRAM_RE REGISTER( VRAM_BASE,0);
#define VRAM_ADR REGISTER ( VRAM_BASE,24576);
//ファイル宣言  
File myFile;

//ov7670レジスタ書き込み用関数
void i2c_ov7670_write(
 unsigned char dev_adr , 
 unsigned char w_adr , 
 unsigned char w_dat ){
 volatile unsigned int *txr_reg = &I2C_TXR; 
 volatile unsigned int *cr_reg = &I2C_CR;  
  *txr_reg = dev_adr;  //デバイスアドレス、書き込みビットを設定
  delay(1);   
  *cr_reg = 0x90;   //送信開始
  delay(5);      // wait
   *txr_reg = w_adr; //レジスタのアドレスを設定
  delay(1);    
   *cr_reg = 0x10;   //送信
  delay(5);  
   *txr_reg = w_dat; //書き込みデータを設定
  delay(1);      
   *cr_reg = 0x50; //送信、送信終了   
  delay(5);  
 }
 
 //I2C初期設定関数
 void i2c_setup() {      
   volatile unsigned int *prerl_reg = &I2C_PRERL; 
   volatile unsigned int *prerh_reg = &I2C_PRERH;    
   volatile unsigned int *ctr_reg = &I2C_CTR;    
   int lp;  
   //I2Cのクロック周波数設定
   Serial.println("i2c set up ");  
   *prerl_reg = 0x1f;  
   *prerh_reg = 0x00;
   *ctr_reg = 0x80;
   delay(200);      // wait  
 }
 
 //カメラ設定関数
void camera_setup() {  
  int lp;
  unsigned char dev_adr = 0x42; //ov7670_adr=0100001,wr=0  
  //カメラ設定データ
  unsigned char ov7670_reg_data [146][2] ={
  {0x12,0x80}, //Rese
  {0x12,0x80}, //Reset
  {0x11,0x01}, //CLKx1
  {0x3A,0x0D}, //TSLB
  {0x12,0x14}, //RGB,QVGA
  {0x40,0xD0}, //RANGE00-FF
  {0x8C,0x02}, //RGB444 enable
  {0x17,0x13}, //HSTART
  {0x18,0x01}, //HSTOP
  {0x32,0xB6}, //HREF
  {0x19,0x02}, //VSTART
  {0x1A,0x7A}, //VSTOP 
  {0x03,0x0A}, //VREF 
  {0x0C,0x00}, //COM3
  {0x3E,0x00}, //COM14
  {0x70,0x3A}, //SCALNG_XCS
  {0x71,0x35}, //SCALNG_YCS
  {0x72,0x11}, //SCALNG_DCWCTR
  {0x73,0xF0}, //SCALNG_PCLK Divied by 1
  {0xA2,0x02}, //SCALNG_PCLK_DELAY
  {0x15,0x00}, //COM10
  {0x13,0xE0}, //COM8 
  {0x00,0x00}, //GAIN 
  {0x10,0x20}, //AECH
  {0x0D,0x40}, //COM14 FUll
  {0x14,0x18}, //COM9 AGC 32x
  {0xA5,0x05}, //BD50MAX 
  {0xAB,0x07}, //BD60MAX
  {0x24,0x95}, //AEW
  {0x25,0x33}, //AEB
  {0x26,0xE3}, //AEB
  {0x9F,0x78}, //HAECC1
  {0xA0,0x68}, //HAECC2
  {0xA1,0x03}, //RSVD
  {0xA6,0xD8}, //HAEC3
  {0xA7,0xD8}, //HAEC4
  {0xA8,0xF0}, //HAEC5
  {0xA9,0x90}, //HAEC6
  {0xAA,0x94}, //HAEC7
  {0x13,0xE5}, //COM8
  {0x0E,0x61}, //COM5 Common Control5
  {0x0F,0x4B}, //COM6 Common Control6
  {0x16,0x02}, //RSVD
  {0x1E,0x07}, //MVFP
  {0x21,0x02},
  {0x22,0x91},
  {0x29,0x07},
  {0x33,0x0B},
  {0x35,0x0B},
  {0x37,0x1D},
  {0x38,0x71},
  {0x39,0x2A},
  {0x3C,0x78},
  {0x4D,0x40},
  {0x4E,0x20},
  {0x69,0x00},
  {0x6B,0x4A},
  {0x74,0x10},
  {0x8D,0x4F},
  {0x8E,0x00},
  {0x8F,0x00},
  {0x90,0x00},
  {0x91,0x00},
  {0x96,0x00},
  {0x9A,0x00},
  {0xB0,0x84},
  {0xB1,0x0C},
  {0xB2,0x0E},
  {0xB3,0x82},
  {0xB8,0x0A},
  {0x43,0x0A},
  {0x44,0xF0},
  {0x45,0x34},
  {0x46,0x58},
  {0x47,0x28},
  {0x48,0x3A},
  {0x59,0x88},
  {0x5A,0x88},
  {0x5B,0x44},
  {0x5C,0x67},
  {0x5D,0x49},
  {0x5E,0x0E},
  {0x6C,0x0A},
  {0x6D,0x55},
  {0x6E,0x11},
  {0x6F,0x9F},
  {0x6A,0x40},
  {0x01,0x40},
  {0x02,0x60},
  {0x13,0xE7},
  {0x4F,0x80},
  {0x50,0x80},
  {0x51,0x00},
  {0x52,0x22},
  {0x53,0x5E},
  {0x54,0x80},
  {0x58,0x9E},
  {0x41,0x08},
  {0x3F,0x00},
  {0x75,0x05},
  {0x76,0xE1},
  {0x4C,0x00},
  {0x77,0x01},
  {0x3D,0xC3},
  {0x4B,0x09},
  {0xC9,0x60},
  {0x41,0x38},
  {0x56,0x50},
  {0x34,0x11},
  {0x3B,0x12},
  {0xA4,0x88},
  {0x96,0x00},
  {0x97,0x30},
  {0x98,0x20},
  {0x99,0x30},
  {0x9A,0x84},
  {0x9B,0x29},
  {0x9C,0x03},
  {0x9D,0x4C},
  {0x9E,0x3F},
  {0x78,0x04},
  {0x79,0x01},
  {0xC8,0xF0},
  {0x79,0x0F},
  {0xC8,0x00},
  {0x79,0x10},
  {0xC8,0xFE},
  {0x79,0x0A},
  {0xC8,0x80},
  {0x79,0x0B},
  {0xC8,0x01},
  {0x79,0x0C},
  {0xC8,0x0F},
  {0x79,0x0D},
  {0xC8,0x20},
  {0x79,0x09},
  {0xC8,0x80},
  {0x79,0x02},
  {0xC8,0xC0},
  {0x79,0x03},
  {0xC8,0x40},
  {0x79,0x05},
  {0xC8,0x30},
  {0x79,0x26},
  {0x55,0xA0}};
  //処理開始
  Serial.println("camera set up start ");  
  for(lp=0;lp<146;lp++){
    i2c_ov7670_write(dev_adr,ov7670_reg_data[lp][0],ov7670_reg_data[lp][1]);
    delay(10);
   } 
  Serial.println("camera set up end ");  
  delay(200);      // wait
}

void sd_set_up() {
  //ピン配置設定
  USPICTL=BIT(SPICP1)|BIT(SPICPOL)|BIT(SPISRE)|BIT(SPIEN)|BIT(SPIBLOCK);
  outputPinForFunction( SDIPIN, IOPIN_USPI_MOSI );
  pinModePPS(SDIPIN,HIGH);
  pinMode(SDIPIN,OUTPUT);
  outputPinForFunction( SCKPIN, IOPIN_USPI_SCK);
  pinModePPS(SCKPIN,HIGH);
  pinMode(SCKPIN,OUTPUT);
  pinModePPS(CSPIN,LOW);
  pinMode(CSPIN,OUTPUT);
  inputPinForFunction( SDOPIN, IOPIN_USPI_MISO );
  pinMode(SDOPIN,INPUT); 
  Serial.print("Initializing SD card...");
  pinMode(10, OUTPUT);
  delay(20);
  //SDカードの初期化
  if (!SD.begin(CSPIN)) {
    Serial.println("initialization failed!");
    return;
  }
  Serial.println("initialization done.");
} 

void setup()
{
  //シリアル通信開始設定
  Serial.begin(9600);  
  delay(2000);      //シリアルモニタ起動する為に2秒待つ
  //I2C初期設定
  i2c_setup();
  //カメラモジュールの設定
  camera_setup();
  //SDカード初期化設定
  sd_set_up();
  //カメラとダミー画像の切替
  pinMode(14, OUTPUT); 
  digitalWrite(14, LOW); //LOW Camera /HIGH Dmy camera
}

void loop()
{
  int i; //アドレス計算用変数
  int v; //ライン数カウント
  int h1;//水平方向カウント1 32バイト毎
  int h2;//水平方向カウント2 バイト毎
  int f_no;//ファイルナンバー
  char f_name_a[10]  = "pic/test"; //ファイル名前半
  char f_name_no[10] ; //ファイルナンバー・ASCIIコード
  char f_name_b[10]  = ".bmp"; //ファイル拡張子
  char f_name[20] ; //ファイル名
  int s_cnt; 
  //制御レジスタ用ポインタ
  volatile unsigned int *vram_read_flg = &VRAM_RE; 
  //VRAM先頭ポンタ
  volatile unsigned int *vram = &VRAM_ADR; 
  //SDRAM書き込み用データ
  unsigned char data_64B [64];
  //バイトアクセス用VRAMポインタ
  unsigned char *ram_data;
  //bmpファイルのヘッダ サイズ128x128
  unsigned char bmp_hd [54] = 
   {0x42,0x4d,0x36,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x36,0x00,0x00,0x00,0x28,0x00,
    0x00,0x00,0x80,0x00,0x00,0x00,0x80,0x00,0x00,0x00,0x01,0x00,0x18,0x00,0x00,0x00,
    0x00,0x00,0x00,0xc0,0x00,0x00,0xc2,0x0e,0x00,0x00,0xc2,0x0e,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00, 0x00,0x00,0x00} ;
  delay(100);      // wait 
  //
  //Serial.println("remove old test*.bmp");
  //古いファイルを削除
  /*
  for(f_no=0;f_no<100;f_no++){
    //ファイル名作成 
    itoa(f_no,f_name_no,10);
    strcpy(f_name,f_name_a);  
    strcat(f_name,f_name_no);
    strcat(f_name,f_name_b);  
    SD.remove(f_name);
    delay(10);  
  }
  */
  //ファイル書き込み処理 100枚
  for(f_no=0;f_no<100;f_no++){
    //ファイル名作成 
    strcpy(f_name,f_name_a);  
    itoa(f_no,f_name_no,10);
    strcat(f_name,f_name_no);
    strcat(f_name,f_name_b);  
    //カメラからのVARAMへの画像書き込み中断
    *vram_read_flg = 0x1;
    //ファイル・オープン
    myFile = SD.open(f_name, FILE_WRITE);
    Serial.println(f_name);    
    // ファイルがオープンできていたら書き込み
    if (myFile) {
      Serial.println("bmp write start");
      //ファイルの先頭へ移動
      myFile.seek(0);
      //BMPヘッダ情報の書き込み
      myFile.write(bmp_hd,54);
      ram_data =   ( unsigned char *)(vram);
      //ラインのカウント
      //BMPファイルは下のラインから始まるので
      //127からデクリメント
      for(v=127;v>=0;v--){
        //水平方向のカウント
        for(h1=0;h1<0x6;h1++){
          for(h2=0;h2<0x20;h2++){
             //アドレス計算
             i= v*0xC0 + h1*0x20 +h2 ;
             //4bitデータを-8bitデータに変換
             data_64B[h2*2]=(*(ram_data+i))&0xf0;
             data_64B[h2*2 + 1]=((*(ram_data+i))&0xf)<<4;
          }
          //64バイト書き込み
          myFile.write(data_64B,64);
        }
       delay(10);  
    }
    //カメラからのVARAMへの画像書き込み再開
    *vram_read_flg = 0x0;
    //ファイル・クローズ
    myFile.flush();
    myFile.close();
    Serial.println("bmp write end");
  }else{
    Serial.println("Open err");
  }
  for(s_cnt=0;s_cnt<5;s_cnt++){
    delay(1000); //待ち時間　1秒
  }
  }
  while(1);
}

