//*****************************************************************************
// File Name            : spi_adc.ino
//-----------------------------------------------------------------------------
// Function             : spi_adc
//                        
//-----------------------------------------------------------------------------
// Designer             : yokomizo 
//-----------------------------------------------------------------------------
// History
// -.-- 2014/09/10 
//*****************************************************************************
     
#include "SPIADC.h"
#include "SPI.h"

void setup()
{
  delay(2000);
  Serial.begin(115200);
  SPI.begin(MOSI(14),MISO(13),SCK(15));// 追加
  analog.begin(CS(12),WISHBONESLOT(6),ADCBITS(SPIADC_12BIT));
  Serial.println("Channel 0\t1\t2\t3\t4\t5\t6\t7");
}
     

void loop() {
  Serial.print("\t");
  for ( int i = 0; i < 8; i++)
  {
    Serial.print(analog.read(i));
    Serial.print("\t");
  }
  Serial.println();
  delay(1000);
}
