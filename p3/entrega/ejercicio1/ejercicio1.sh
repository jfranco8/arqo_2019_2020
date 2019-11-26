#!/bin/bash

# Arquitectura de ordenadores 2019/2020
# Practica 3
#
# Ejercicio 1
#
# Jesus Daniel Franco Lopez
# Grupo 1362
# Pareja 44

# Semilla P
# P = (44 mod 7) + 4 = 2 + 4 = 6

make clean
make

# Inicializamos las variables
NInicio=10000+1024*6 # Tamaño donde empezarán a iterar las matrices
NPaso=64 # Tamaño de iteración
NFinal=$((NInicio + 1024)) # Tamaño al que llegarán las matrices
fDAT=time_slow_fast.dat # Fichero donde volcaremos los datos
fPNG=time_slow_fast.png # Imagen donde mostraremos la gráfica
NumRep=15 # Numero de repeticiones del programa, para obtener un resultado más ajustado

# Borramos el fihero DAT y la imagen por si las teníamos creadas de antes
# y generamos el fichero DAT vacío
rm -f $fDAT fPNG
touch $fDAT

echo ""
echo "------------------------------------------"
echo "| Práctica 3 - ARQO                      |"
echo "| Ejercicio 1                            |"
echo "| 2019 - 2020                            |"
echo "| Grupo 1362 Pareja 44                   |"
echo "| Jesus Daniel Franco Lopez              |"
echo "------------------------------------------"
echo ""
echo "Hora de comienzo de ejecución:"
date +"%T"
echo ""
echo "Ejecutando slow y fast..."

# Bucle for para recorrer las matrices atendiendo al tamaño inicial,
# el tamaño final y el tamaño de iteración (NPaso)
for ((N = NInicio ; N <= NFinal ; N += 2*NPaso)); do
	echo "N: $N / $NFinal..."

	# Inicializamos los valores de los tiempos de ejecución a cero para cada uno de
	# los tamaños de matrices que vamos a usar.
	slowAux1=0
	slowAux2=0
	fastAux1=0
	fastAux2=0

	# Ejecutamos los programas slow y fast para N y N+NPaso tantas veces como
	# repeticiones hayamos estipulado
	for ((i = 0; i < NumRep; i++)); do
		# Seleccionaremos la columna tercera de la linea que contiene el tiempo de la
		# salida de cada uno de los programas para guardarlos en las variables
		# que inicializamos anteriormente
		slowAux1=$(awk '{print $1+$2}' <<<"$slowAux1 $(./slow $N | grep 'time' | awk '{print $3}')")
		slowAux2=$(awk '{print $1+$2}' <<<"$slowAux2 $(./slow $((N+NPaso)) | grep 'time' | awk '{print $3}')")
		fastAux1=$(awk '{print $1+$2}' <<<"$fastAux1 $(./fast $N | grep 'time' | awk '{print $3}')")
		fastAux2=$(awk '{print $1+$2}' <<<"$fastAux2 $(./fast $((N+NPaso)) | grep 'time' | awk '{print $3}')")
	done
	# Como se puede observar, hemos intercalado la ejecución de los programas como se
	# pide en el enunciado. Al hacer dos tamaños de golpe, el bucle primero itera
	# sumando 2*NPaso

	# Guardamos en el fichero DAT los valores obtenidos
	# seguimos el formato
	#		N tiempo_slow tiempo_fast
	slowTime=$(awk '{print $1/$2}' <<<"$slowAux1 $NumRep")
	fastTime=$(awk '{print $1/$2}' <<<"$fastAux1 $NumRep")
	echo "$N	$slowTime	$fastTime" >> $fDAT

	slowTime=$(awk '{print $1/$2}' <<<"$slowAux2 $NumRep")
	fastTime=$(awk '{print $1/$2}' <<<"$fastAux2 $NumRep")
	echo "$((N+NPaso))	$slowTime	$fastTime" >> $fDAT


done

# Generamos la gráfica con GNUPLOT
echo "Generando grafica con GNUPLOT..."
gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT

echo "Hora de finalización de ejecución:"
date +"%T"

# Acabamos la ejecución y hacemos make clean
make clean
