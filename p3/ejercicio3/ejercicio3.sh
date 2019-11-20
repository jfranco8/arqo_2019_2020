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
clear

# Inicializar variables
NInicio=256+256*6
NPaso=16
NFinal=$((NInicio + 256))
NumRep=10

fDat=mult.dat

# borrar los ficheros DAT y el fichero PNG
rm -f *.dat *.png

# Generamos los ficheros vacios

touch aux.dat normalAux.dat traspAux.dat $fDat

echo ""
echo "------------------------------------------"
echo "| Práctica 3 - ARQO                      |"
echo "| Ejercicio 3                            |"
echo "| 2019 - 2020                            |"
echo "| Grupo 1362 Pareja 44                   |"
echo "| Jesus Daniel Franco Lopez              |"
echo "------------------------------------------"
echo ""
echo "Hora de comienzo de ejecución:"
date +"%T"
echo ""
echo "Ejecutando ejercicio 3..."

# Recorremos los tamaños de las matrices
for ((N = NInicio ; N <= NFinal ; N += 2*NPaso)); do
	echo "	- N: $N / $NFinal..."

	# Inicializamos a cero las variables en las que guardamos los tiempos de ejecucion
	normalTimeAux1=0
	normalTimeAux2=0
	traspTimeAux1=0
	traspTimeAux2=0

	# Calculamos los fallos de caché de la multiplicacion normal para N1
	valgrind -q --tool=cachegrind --cachegrind-out-file=aux.dat -q ./multNormal $N >&/dev/null
	echo $(cg_annotate aux.dat | head -n 30 | grep 'PROGRAM TOTALS' | sed -u 's/,//g') > normalAux.dat
	normalAux1D1Mr=$(awk '{print $5}' normalAux.dat)
	normalAux1D1Mw=$(awk '{print $8}' normalAux.dat)

	# Calculamos los fallos de caché de la multiplicacion traspuesta para N1
	valgrind -q --tool=cachegrind --cachegrind-out-file=aux.dat -q ./multTraspuesta $N >&/dev/null
	echo $(cg_annotate aux.dat | head -n 30 | grep 'PROGRAM TOTALS' | sed -u 's/,//g') > traspAux.dat
	traspAux1D1Mr=$(awk '{print $5}' traspAux.dat)
	traspAux1D1Mw=$(awk '{print $8}' traspAux.dat)

	# Calculamos los fallos de caché de la multiplicacion normal para N2
	valgrind -q --tool=cachegrind --cachegrind-out-file=aux.dat -q ./multNormal $((N + NPaso)) >&/dev/null
	echo $(cg_annotate aux.dat | head -n 30 | grep 'PROGRAM TOTALS' | sed -u 's/,//g') > normalAux.dat
	normalAux2D1Mr=$(awk '{print $5}' normalAux.dat)
	normalAux2D1Mw=$(awk '{print $8}' normalAux.dat)

	# Calculamos los fallos de caché de la multiplicacion traspuesta para N2
	valgrind -q --tool=cachegrind --cachegrind-out-file=aux.dat -q ./multTraspuesta $((N + NPaso)) >&/dev/null
	echo $(cg_annotate aux.dat | head -n 30 | grep 'PROGRAM TOTALS' | sed -u 's/,//g') > traspAux.dat
	traspAux2D1Mr=$(awk '{print $5}' traspAux.dat)
	traspAux2D1Mw=$(awk '{print $8}' traspAux.dat)

	# Calculamos el tiempo de ejecución para cada uno de los programas
	# de manera intercalada, tal y como se nos pide en el enunciado
	for ((i = 0; i < NumRep; i++)); do
		normalTimeAux1=$(awk '{print $1+$2}' <<< "$normalTimeAux1 $(./multNormal $N | grep 'time' | awk '{print $3}')")
		traspTimeAux1=$(awk '{print $1+$2}' <<< "$traspTimeAux1 $(./multTraspuesta $N | grep 'time' | awk '{print $3}')")
		normalTimeAux2=$(awk '{print $1+$2}' <<< "$normalTimeAux2 $(./multNormal $((N + NPaso)) | grep 'time' | awk '{print $3}')")
		traspTimeAux2=$(awk '{print $1+$2}' <<< "$traspTimeAux2 $(./multTraspuesta $((N + NPaso)) | grep 'time' | awk '{print $3}')")
	done

	# Calculamos el tiempo medio de ejecucion para cada programa y cada tamaño
	# y lo guardamos en el .dat junto a los fallos de caché

	normalTimeAux1=$(awk '{print $1/$2}' <<< "$normalTimeAux1 $NumRep")
	traspTimeAux1=$(awk '{print $1/$2}' <<< "$traspTimeAux1 $NumRep")

	echo "$N $normalTimeAux1 $normalAux1D1Mr $normalAux1D1Mw $traspTimeAux1 $traspAux1D1Mr $traspAux1D1Mw" >> $fDat

	normalTimeAux2=$(awk '{print $1/$2}' <<< "$normalTimeAux2 $NumRep")
	traspTimeAux2=$(awk '{print $1/$2}' <<< "$traspTimeAux2 $NumRep")

	echo "$((N + NPaso)) $normalTimeAux2 $normalAux2D1Mr $normalAux2D1Mw	$traspTimeAux2 $traspAux2D1Mr	$traspAux2D1Mw" >> $fDat

done


echo "Generando grafica con GNUPLOT..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"

# FALLOS EN CACHÉ DE CADA PROGRAMA
gnuplot << END_GNUPLOT
set title "Fallos cache normal-traspuesta"
set ylabel "Num Fallos"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "mult_cache.png"
plot "$fDat" using 1:3 with lines lw 2 title "Normal D1Mr", \
		 "$fDat" using 1:4 with lines lw 2 title "Normal D1Mw", \
		 "$fDat" using 1:6 with lines lw 2 title "Trasp D1Mr", \
		 "$fDat" using 1:7 with lines lw 2 title "Trasp D1Mw"
replot
quit
END_GNUPLOT

# TIEMPO DE EJECUCIÓN DE CADA PROGRAMA
gnuplot << END_GNUPLOT
set title "Tiempo ejecucion normal-traspuesta"
set ylabel "Tiempo (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "mult_time.png"
plot "$fDat" using 1:2 with lines lw 2 title "Normal", \
		 "$fDat" using 1:5 with lines lw 2 title "Traspuesta"
replot
quit
END_GNUPLOT

echo "Hora de finalización de ejecución:"
date +"%T"
