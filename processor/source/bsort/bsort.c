#include "sf-types.h"
#include "bsort-input.h"

volatile unsigned int *gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;

int main()
{
	int maxindex = bsort_input_len - 1;

	/* Start with LED on. */
	*gDebugLedsMemoryMappedRegister = 0xFF;

	/* Sort. */
	while (maxindex > 0)
	{
		for (int i = 0; i < maxindex; i++)
		{
			if (bsort_input[i] > bsort_input[i + 1])
			{
				/* Swap. */
				bsort_input[i] ^= bsort_input[i + 1];
				bsort_input[i + 1] ^= bsort_input[i];
				bsort_input[i] ^= bsort_input[i + 1];
			}
		}

		maxindex--;
	}

	/* Verify results. */
	int delta = 0;
	for (int i = 0; i < bsort_input_len; i++)
		delta |= bsort_input[i] ^ correct_arr[i];

	/* Turn off LED if the array is now sorted. */
	if (!delta)
		*gDebugLedsMemoryMappedRegister = 0x00;

	for (int i = 0; i < 400000; i++)
	{
		/* Spin! */
	}

	return 0;
}
