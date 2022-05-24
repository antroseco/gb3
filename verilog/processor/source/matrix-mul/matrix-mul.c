#include "matrix-mul.h"
#include <stdio.h>

volatile unsigned int *		gDebugLedsMemoryMappedRegister = (unsigned int *)0x2000;

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
	/*matrix_mul(matrix_a, matrix_b, &out, 4, 4, 4);*/
	int n = 4;
	int m = 4;
	int p = 4;

	*gDebugLedsMemoryMappedRegister = 0xFF;
	for (int i = 0; i < n; i++) {
		for (int j = 0; j < p; j++) {
			out[i][j] = 0;
			for (int k = 0; k < m; k++) {
				out[i][j] += matrix_a[i][k] * matrix_b[k][j];
			}
		}
	}
	*gDebugLedsMemoryMappedRegister = 0x00;
	/*for (int i = 0; i < n; i++) {*/
		/*for (int j = 0; j < p; j++) {*/
			/*printf("%d ", out[i][j]);*/
		/*}*/
		/*printf("\n");*/
	/*}*/
	return 0;
}

/*void matrix_mul(int** matrix_a, int** matrix_b, int*** out, int n, int m, int p) {*/
	/*
	 * (n x m) * (m x p)
	 */
	/*for (int i = 0; i < n; i++) {*/
		/*for (int j = 0; j < p; j++) {*/
			/*// ij*/
			/**out[i][j] = 0;*/
			/*for (int k = 0; k < m; k++) {*/
				/**out[i][j] += matrix_a[i][k] * matrix_b[k][j];*/
			/*}*/
		/*}*/
	/*}*/
/*}*/
