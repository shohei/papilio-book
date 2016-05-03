//*****************************************************************************
// File Name            : vga_test.ino
//-----------------------------------------------------------------------------
// Function             : vga write
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10 
//*****************************************************************************
#define VGABASE IO_SLOT(9)
#define VGAPTR REGISTER(VGABASE,0);
#define HSIZE (800/5)    /* 160 */
#define VSIZE (600/5)    /* 120 */

void setup() {
}  
void loop()
{
int c,xp,yp;
volatile unsigned int *vmem ;
const char colors[4]={0xFF,0xE0,0x1C,0x3};
  while (1){
    for(c=0;c<4;c++) {//色変更
      vmem = &VGAPTR; //ポインタを先頭に戻す
      for(yp=0;yp<VSIZE ;yp++)   //縦位置
        for(xp=0;xp<HSIZE ;xp++){ //横位置
          *vmem =colors[c]; //ピクセル書き込み
          vmem++; //アドレス加算
          delay(1); //遅延 
        } 
    } 
  }	 
}

