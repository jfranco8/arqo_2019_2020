#!/bin/bash

# Arquitectura de ordenadores 2019/2020
# Practica 4
#
# Ejercicio 3
#
# Jesus Daniel Franco Lopez
# Grupo 1362
# Pareja 44

# Semilla P
# P = (44 mod 8) + 1 = 4 + 1 = 5

make clean
make
clear

# Inicializar variables
NInicio=512+5
NPaso=64
NFinal=$((NInicio + 1024))
NumRep=3


# borrar los ficheros DAT y el fichero PNG
rm -f e3_tiempos_hilo_1.dat e3_tiempos_hilo_2.dat e3_tiempos_hilo_3.dat e3_tiempos_hilo_4.dat e3_aceleracion_hilo_1.dat e3_aceleracion_hilo_2.dat e3_aceleracion_hilo_3.dat e3_aceleracion_hilo_4.dat e3.png e3_aceleracion.png
# Generamos los ficheros vacios
touch e3_tiempos_hilo_1.dat e3_tiempos_hilo_2.dat e3_tiempos_hilo_3.dat e3_tiempos_hilo_4.dat e3_aceleracion_hilo_1.dat e3_aceleracion_hilo_2.dat e3_aceleracion_hilo_3.dat e3_aceleracion_hilo_4.dat

echo ""
echo "------------------------------------------"
echo "| Práctica 4 - ARQO                      |"
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

for((hilo = 1; hilo<=4; hilo++));do
echo "Hilo $hilo / 4..."
	for ((N = NInicio ; N <= NFinal ; N += NPaso)); do
		echo "	- N: $N / $NFinal..."

		if((hilo==1)); then
			normalTime=0
		else
			normalTime=$(awk -v var="$N" '{if ($1 == var) print $2}' e3_tiempos_hilo_1.dat)
		fi

		normalTimePar3=0

		for ((i = 0; i < NumRep; i++)); do
			if((hilo==1)); then
				normalTime=$(awk '{print $1+$2}' <<< "$normalTime $(./multNormal $N | grep 'time' | awk '{print $3}')")
			fi
			normalTimePar3=$(awk '{print $1+$2}' <<< "$normalTimePar3 $(./multNormal_par3 $N $hilo | grep 'time' | awk '{print $3}')")
		done

		normalTime=$(awk '{print $1/$2}' <<< "$normalTime $NumRep")
		normalTimePar3=$(awk '{print $1/$2}' <<< "$normalTimePar3 $NumRep")

		echo "$N $normalTime $normalTimePar3" >> e3_tiempos_hilo_"$hilo".dat

		normalAcPar3=$(awk '{print $1/$2}' <<< "$normalTime $normalTimePar3")

		echo "$N $normalAcPar3" >> e3_aceleracion_hilo_"$hilo".dat

	done
done


echo "Generating plot"
gnuplot << END_GNUPLOT
set title "Tiempos ejecucion"
set ylabel "Tiempos"
set xlabel "Tamaños"
set key right bottom
set grid
set term png
set output "e3.png"
plot "e3_tiempos_hilo_1.dat" using 1:2 with lines lw 2 title "serie", \
     "e3_tiempos_hilo_4.dat" using 1:3 with lines lw 2 title "Hilo 4"
replot
quit
END_GNUPLOT

gnuplot << END_GNUPLOT
set title "Aceleracion Tiempos ejecucion"
set ylabel "Aceleracion"
set xlabel "Tamaños"
set key right bottom
set grid
set term png
set output "e3_aceleracion.png"
plot "e3_aceleracion_hilo_4.dat" using 1:2 with lines lw 2 title "Hilo 4"
replot
quit
END_GNUPLOT
