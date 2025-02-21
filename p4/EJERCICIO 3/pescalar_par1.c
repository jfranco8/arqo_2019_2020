// ----------- Arqo P4-----------------------
// pescalar_par1
//
#include <stdio.h>
#include <stdlib.h>
#include "arqo4.h"

int main(int argc, char *argv[])
{
	float *A=NULL, *B=NULL;
	long long k=0;
	struct timeval fin,ini;
	float sum=0;
	
	int size;
	if(argc!=2){
		printf("Introduce el tamano de los vectores a crear");
		return -1;
	}
	size = atoi(argv[1]);

	A = generateVector(size);
	B = generateVector(size);
	if ( !A || !B )
	{
		printf("Error when allocationg matrix\n");
		freeVector(A);
		freeVector(B);
		return -1;
	}
	
	gettimeofday(&ini,NULL);
	/* Bloque de computo */
	sum = 0;
	#pragma omp parallel for
	for(k=0;k<size;k++)
	{
		sum = sum + A[k]*B[k];
	}
	/* Fin del computo */
	gettimeofday(&fin,NULL);

	printf("Resultado: %f\n",sum);
	printf("Tiempo: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	freeVector(A);
	freeVector(B);

	return 0;
}
