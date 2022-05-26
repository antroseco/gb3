#include "sf-types.h"
/*#include "sh7708.h"*/
/*#include "devscc.h"*/
/*#include "print.h"*/
#include "bsort-input.h"

volatile unsigned int *		gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;

int
main(void)
{
	int i;
	int maxindex = bsort_input_len - 1;

	/**gDebugLedsMemoryMappedRegister = 0x00;*/

	*gDebugLedsMemoryMappedRegister = 0xFF; //start with LED on


	/*print("\n\n[%s]\n", bsort_input);*/
	while (maxindex > 0)
	{
		for (i = 0; i < maxindex; i++)
		{
			if (bsort_input[i] > bsort_input[i+1])
			{
				/*		swap		*/
				bsort_input[i] ^= bsort_input[i+1];
				bsort_input[i+1] ^= bsort_input[i];
				bsort_input[i] ^= bsort_input[i+1];
			}
		}

		maxindex--;
	}
	int check = 1;
	for (int i=0; i<bsort_input_len; i++){
		if (bsort_input[i] != correct_arr[i]){
			check = 0;
		}
	}

	if (check)
	{
		*gDebugLedsMemoryMappedRegister = 0x00; //LED turns off
		// for (int j = 0; j < 4000; j++); //delay for an interval
	}

	for (int i = 0; i < 200000; i++) {}

	return 0;
}
