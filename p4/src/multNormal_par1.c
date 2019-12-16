/**********************************************
*
* ARQUITECTURA DE ORDENADORES
*
* PRACTICA 3 EJERCICIO 3
*
* multNormal.c
*
* Grupo 1362 Pareja 44
*
* Jesus Daniel Franco Lopez
*
**********************************************/


#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include "arqo3.h"


/*
* CALCULAR
*
* Calcula la multiplicacion de 2 matrices, a y b, con un tamano dado n.
*
* Guarda en la matriz resultado la multiplicacion calculada
*/

void calcular(int n, tipo **a, tipo **b, tipo** resultado){
	// Inicializamos los contadores
	int i = 0, j = 0, k = 0;

	printf("\t --- MATRIZ RESULTADO ---\n");
	for(i = 0; i < n; i++){
		for(j = 0; j < n; j++){
			#pragma omp parallel for reduction(+:sum) private (k) shared(resultado,a,b,n)
			for (k = 0; k < n; k++){
				// Guardamos el resultado de la multiplicacion en la matriz resultado
				resultado[i][j] += a[i][k]*b[k][j];
			}
			printf("%lf\t", resultado[i][j]);
		}
		printf("\n");
	}
}


/*
* IMPRIMIR_MATRIZ
*
* imprime por pantalla la matriz a pasada como argumento
*/
void imprimir_matriz(tipo **a, int size){
	int i, j;
	for(i = 0; i < size; i++){
		for(j = 0; j < size; j++){
			printf("%lf\t", a[i][j]);
		}
		printf("\n");
	}
}

int main(int argc, char *argv[]){

  int n = 0;
	struct timeval inicio, fin;

  /* MATRICES */
	tipo **a = NULL;
	tipo **b = NULL;
	tipo **resultado = NULL;

	// COMPROBACION DE ERRORES

	if(argc != 2){
		printf("Error en los parametros de entrada: ./%s <size>\n", argv[0]);
		return -1;
	}

	n = atoi(argv[1]);
	if(n <= 0){
    printf("Error en los parametros de entrada: size tiene que ser un entero > 0\n");
		return -1;
  }

	// CREAMOS LAS MATRICES OPERANDOS
	if(!(a = generateMatrix(n)) || !(b = generateMatrix(n))){
		return -1;
	}

	printf("\t --- MATRIZ A ---\n");
	imprimir_matriz(a, n);
	printf("\t --- MATRIZ B ---\n");
	imprimir_matriz(b, n);

	// CREAMOS LA MATRIZ RESULTADO
	if (!(resultado = generateEmptyMatrix(n))){
		return -1;
	}

	gettimeofday(&inicio, NULL);
  /* Calculamos la multiplicacion entre las 2 matrices generadas */
  calcular(n, a, b, resultado);
  gettimeofday(&fin, NULL);
  printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(inicio.tv_sec*1000000+inicio.tv_usec))*1.0/1000000.0);

	freeMatrix(a);
	freeMatrix(b);
	freeMatrix(resultado);

	return 0;
}
