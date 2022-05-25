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

	*gDebugLedsMemoryMappedRegister = 0xFF;


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
	*gDebugLedsMemoryMappedRegister = 0x00;

	for (int i = 0; i < 40000; i++) {}
	/**gDebugLedsMemoryMappedRegister = 0xFF;*/

	/*print("[%s]\n", bsort_input);*/

	return 0;
}
