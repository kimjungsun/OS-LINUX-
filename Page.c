
#include "Page.h"
void kInitializePageTables( void )
{
	PML4TENTRY* pstPML4TEntry;
	PDPTENTRY* pstPDPTEntry;
	PDENTRY* pstPDEntry;
	PTENTRY* pstPTEntry;               //Page Table setting
	DWORD dwMappingAddress;
	DWORD dwMappingAddress2;           // 0x1000 (4kb) size
	int i;
	///////////////////
//pstPML4Entry 
//
//
	pstPML4TEntry = ( PML4TENTRY* ) 0x100000;
	kSetPageEntryData( &( pstPML4TEntry[ 0 ] ), 0x00, 0x101000, PAGE_FLAGS_DEFAULT,
			0 );
	for( i = 1 ; i < PAGE_MAXENTRYCOUNT ; i++ )
	{
		kSetPageEntryData( &( pstPML4TEntry[ i ] ), 0, 0, 0, 0 );
	}
/////////////////////////////////
//pstPDPTEntry 
//
	pstPDPTEntry = ( PDPTENTRY* ) 0x101000;
	for( i = 0 ; i < 64 ; i++ )
	{
		kSetPageEntryData( &( pstPDPTEntry[ i ] ), 0, 0x102000 + ( i * PAGE_TABLESIZE ), 
				PAGE_FLAGS_DEFAULT, 0 );
	}
	for( i = 64 ; i < PAGE_MAXENTRYCOUNT ; i++ )
	{
		kSetPageEntryData( &( pstPDPTEntry[ i ] ), 0, 0, 0, 0 );
	}
/////////////////////////////////
//Set Data : pstPDEntry & pstPTEntry both 
//
	pstPDEntry = ( PDENTRY* ) 0x102000;  // Page Directory initial address
	dwMappingAddress = 0;

	pstPTEntry = (PTENTRY*) 0x142000; // PageTable initial address 
	dwMappingAddress2 = 0;

	kSetPageEntryData( &(pstPDEntry[0]), 0,0x142000,PAGE_FLAGS_DEFAULT,0);
		dwMappingAddress += PAGE_DEFAULTSIZE;   // [0] address == PT initial address 
      // PT ENTRY 0 ~ 511 == 000~1FE // due to 1FF : read only district
    for(int k=0; k<511;k++){
		kSetPageEntryData( &(pstPTEntry[k]), 0,dwMappingAddress2,
				PAGE_FLAGS_DEFAULT, 0); // upper :0 why? under 512b

		dwMappingAddress2 += 0x1000;
	}

		kSetPageEntryData( &(pstPTEntry[511]), 0,dwMappingAddress2,
				PAGE_FLAGS_P, 0);  // Page_flag_default == p | r/w
		                           // r/w = 0
								   //  thus, only page_flag_p
    // restart PDEntry from i == 1
	for( i = 1 ; i < 5 ; i++ )
	{
		kSetPageEntryData( &( pstPDEntry[ i ] ), 
				( i * ( PAGE_DEFAULTSIZE >> 20 ) ) >> 12, dwMappingAddress, 
				PAGE_FLAGS_DEFAULT | PAGE_FLAGS_PS, 0 );
		dwMappingAddress += PAGE_DEFAULTSIZE;
	}
	// part of 'video memory address AB8000 relocated to B8000'
	//  A = 1010 , 0 : last 21th bit of offest , thus 101 == 5 ,[5]array set up
		kSetPageEntryData( &(pstPDEntry[5]),(0 * ( PAGE_DEFAULTSIZE >> 20 ) ) >> 12, 0,PAGE_FLAGS_DEFAULT | PAGE_FLAGS_PS, 0 );
		dwMappingAddress += PAGE_DEFAULTSIZE;

	for( i = 6 ; i < PAGE_MAXENTRYCOUNT * 64 ; i++ )
	{
		kSetPageEntryData( &( pstPDEntry[ i ] ), 
				( i * ( PAGE_DEFAULTSIZE >> 20 ) ) >> 12, dwMappingAddress, 
				PAGE_FLAGS_DEFAULT | PAGE_FLAGS_PS, 0 );
		dwMappingAddress += PAGE_DEFAULTSIZE;
	}
     	
}

void kSetPageEntryData( PTENTRY* pstEntry, DWORD dwUpperBaseAddress,
		DWORD dwLowerBaseAddress, DWORD dwLowerFlags, DWORD dwUpperFlags )
{
pstEntry->dwAttributeAndLowerBaseAddress = dwLowerBaseAddress | dwLowerFlags;
	pstEntry->dwUpperBaseAddressAndEXB = ( dwUpperBaseAddress & 0xFF ) | 
		dwUpperFlags;
}
