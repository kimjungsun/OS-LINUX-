
#include "Types.h"

void kPrintString( int iX, int iY, const char* pcString );

void Main( void )
{

    kPrintString( 0, 4, "Switch To IA-32e Mode Success~!!" );
    kPrintString( 0, 5, "C Language Kernel Start.............[PASS]" );
	kPrintString(0,6,"This message is printed through the video memory relocated to 0xAB8000");
    canRead(0x1FE000);
	kPrintString(0,7,"0x1fE000: Read [OK]");
    canWrite(0x1FE000);
	kPrintString(0,8,"0x1fE000: Write [OK]");
    canRead(0x1FF000);
	kPrintString(0,9,"0x1ff000: Read [OK]");
	while(1);
  //  canWrite(0x1FF000);
  //	kPrintString(0,18,"0x1ff000: Write[OK]");
}
void canRead(char* readAddress){
    char temp ;
	temp =  readAddress[0];
	
}
void canWrite(char* writeAddress){
    writeAddress[0] = 1;
}
void kPrintString( int iX, int iY, const char* pcString )
{
    CHARACTER* pstScreen = ( CHARACTER* ) 0xAB8000;
    int i;
    
    pstScreen += ( iY * 80 ) + iX;
    
    for( i = 0 ; pcString[ i ] != 0 ; i++ )
    {
        pstScreen[ i ].bCharactor = pcString[ i ];
    }
}

