#include <stdio.h>

/*#define DEBUG*/

volatile unsigned int *		gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;

void matrix_mul(int* matrix_a, int* matrix_b, int *out, int n, int m, int p) {
	/*(n x m) * (m x p)*/
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < p; j++) {
			// note that there actually isn't a neater way to do this because
			// you can't pass int foo[][] into a function in C lol
			*(out+n*i+j) = 0;
			for (int k = 0; k < m; k++) {
				*(out+n*i+j)  += *(matrix_a+n*i+k) * *(matrix_b+k*m+j);
			}
		}
	}
}

int main(void)
{
	int matrix_a[4][4] = {
		{5, 2, 6, 1},
		{0, 6, 2, 0},
		{3, 8, 1, 4},
		{1, 8, 5, 6},
	};
	int matrix_b[4][4] = {
		{7, 5, 8, 0},
		{1, 8, 2, 6},
		{9, 4, 3, 8},
		{5, 3, 7, 9},
	};
	int out[4][4];

#ifndef DEBUG
	*gDebugLedsMemoryMappedRegister = 0xFF;
#endif /* ifndef  */

	matrix_mul((int*)matrix_a, (int*)matrix_b, (int*)out, 4, 4, 4);

#ifndef DEBUG
	*gDebugLedsMemoryMappedRegister = 0x00;
#endif /* ifndef  */

#ifdef DEBUG
	for (int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			printf("%d ", out[i][j]);
		}
		printf("\n");
	}
#endif /* ifndef  */

	return 0;
}

