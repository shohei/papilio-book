//*****************************************************************************
// File Name            : userreg_test.ino
//-----------------------------------------------------------------------------
// Function             :  userreg test
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10 
//*****************************************************************************
#include <SevenSegHW.h>
//zpuino_userregが使うスロット13のアドレス定義
#define UREGBase IO_SLOT(13)
//レジスタのアドレス定義
//zpuino_userregのアドレス0 出力用レジスタのアドレス
#define UREG_OUT REGISTER(UREGBase,0);
//zpuino_userregのアドレス4 入力用レジスタのアドレス
#define UREG_IN REGISTER(UREGBase,1);
SEVENSEGHW sevenseg;
void setup() {
sevenseg.begin(12);
}
void loop() {
int lp;
int data;
int data_d;
Serial.begin(9600);
//userregのレジスタ用ポインタ
volatile unsigned int *ureg_out = &UREG_OUT;
volatile unsigned int *ureg_in = &UREG_IN;
data=1;
//LEDを順番に点灯
for(lp=1;lp<256;lp=lp*2){
*ureg_out = lp;
delay(500); // wait for a 500ms
}
while(1){
data = *ureg_in; //入力用データの読み込み
*ureg_out =data; //読み込んだデータを出力用レジスタへ書き込み
sevenseg.setHexValue(data); //読み込んだデータを7セグメントLEDで表示
//過去のデータと違った場合
if(data != data_d)
Serial.println(data,HEX); //データをシリアル通信で送信
data_d = data; //比較用データの保存
delay(100);
}
}
