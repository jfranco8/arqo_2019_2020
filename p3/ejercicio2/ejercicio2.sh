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

# Inicializar variables
NInicio=2000+512*6 # Valor de inicio para el tamaño de las matrices
NPaso=64 # Diferencia de tamaño para cada iteración
NFinal=$((NInicio + 512)) # Tamaño máximo de las matrices
TamLinea=64 # Tamaño de linea
cacheIni=1024 # Tamaño de la cache mas pequeña
cacheFin=8192 # Tamaño de la cache de mayor tamaño
NumRep=3 # numero de repeticiones

# borrar los ficheros DAT y el fichero PNG
rm -f *.dat *.png

# Generamos los ficheros vacios

touch slow.dat fast.dat slowAux.dat fastAux.dat

echo ""
echo "------------------------------------------"
echo "| Práctica 3 - ARQO                      |"
echo "| Ejercicio 2                            |"
echo "| 2019 - 2020                            |"
echo "| Grupo 1362 Pareja 44                   |"
echo "| Jesus Daniel Franco Lopez              |"
echo "------------------------------------------"
echo ""
echo "Hora de comienzo de ejecución:"
date +"%T"
echo ""
echo "Ejecutando ejercicio 2..."

# Bucle para ir recorriendo las cachés según su tamaño
# Los tamaños que comprobaremos serán 1024, 2045, 4096, 8192
for ((size = cacheIni ; size <= cacheFin ; size*=2)); do
	# Tamaño de caché actual
	echo "Size: $size /$cacheFin"
	# Para cada caché recooremos las matrices por todos sus tamaños
	# Iremos alternando tamaños para la ejecución de fast y slow, por lo que el
	# bucle llegará iterará segón 2*Npaso
	for ((N = NInicio ; N <= NFinal ; N += 2*NPaso)); do
		echo "	- N: $N / $NFinal..."

		# Inicializamos los valores de la cantidad de fallos a cero para cada uno
		# de los tamaños de la matriz.
		# slowAux1D1Mr = numero de fallos para en lectura para el programa slow
		# 							 con el primero de los tamaños de matrices (N1)
		slowAux1D1Mr=0
		slowAux1D1Mw=0
		slowAux2D1Mr=0
		slowAux2D1Mw=0
		fastAux1D1Mr=0
		fastAux1D1Mw=0
		fastAux2D1Mr=0
		fastAux2D1Mw=0

		for ((i = 0; i < NumRep; i++)); do

			# Ejecutamos el programa slow para el tamaño de matrices N1
			valgrind -q --tool=cachegrind --cachegrind-out-file=slow.dat  --I1=$size,1,$TamLinea --D1=$size,1,$TamLinea --LL=8388608,1,$TamLinea ./slow $N >&/dev/null
			echo $(cg_annotate slow.dat | head -n 30 | grep 'PROGRAM TOTALS' | sed -u 's/,//g') > slowAux.dat

			slowAux1D1Mr=$(awk '{print $1+$2}' <<< "$slowAux1D1Mr $(awk '{print $5}' slowAux.dat)")
			slowAux1D1Mw=$(awk '{print $1+$2}' <<< "$slowAux1D1Mw $(awk '{print $8}' slowAux.dat)")

			# Ejecutamos el programa fast para el tamaño de matrices N1
			valgrind -q --tool=cachegrind --cachegrind-out-file=fast.dat  --I1=$size,1,$TamLinea --D1=$size,1,$TamLinea --LL=8388608,1,$TamLinea ./fast $N >&/dev/null
			echo $(cg_annotate fast.dat | head -n 30 | grep 'PROGRAM TOTALS' | sed -u 's/,//g') > fastAux.dat

			fastAux1D1Mr=$(awk '{print $1+$2}' <<< "$fastAux1D1Mr $(awk '{print $5}' fastAux.dat)")
			fastAux1D1Mw=$(awk '{print $1+$2}' <<< "$fastAux1D1Mw $(awk '{print $8}' fastAux.dat)")

			# Ejecutamos el programa slow para el tamaño de matrices N2
			valgrind -q --tool=cachegrind --cachegrind-out-file=slow.dat  --I1=$size,1,$TamLinea --D1=$size,1,$TamLinea --LL=8388608,1,$TamLinea ./slow $((N+NPaso)) >&/dev/null
			echo $(cg_annotate slow.dat | head -n 30 | grep 'PROGRAM TOTALS' | sed -u 's/,//g') > slowAux.dat

			slowAux2D1Mr=$(awk '{print $1+$2}' <<< "$slowAux2D1Mr $(awk '{print $5}' slowAux.dat)")
			slowAux2D1Mw=$(awk '{print $1+$2}' <<< "$slowAux2D1Mw $(awk '{print $8}' slowAux.dat)")

			# Ejecutamos el programa fast para el tamaño de matrices N2
			valgrind -q --tool=cachegrind --cachegrind-out-file=fast.dat  --I1=$size,1,$TamLinea --D1=$size,1,$TamLinea --LL=8388608,1,$TamLinea ./fast $((N+NPaso)) >&/dev/null
			echo $(cg_annotate fast.dat | head -n 30 | grep 'PROGRAM TOTALS' | sed -u 's/,//g') > fastAux.dat

			fastAux2D1Mr=$(awk '{print $1+$2}' <<< "$fastAux2D1Mr $(awk '{print $5}' fastAux.dat)")
			fastAux2D1Mw=$(awk '{print $1+$2}' <<< "$fastAux2D1Mw $(awk '{print $8}' fastAux.dat)")
		done

		# Hacemos la media para cada uno de los fallos obtenidos y las repeticiones
		# realzadas

		slowD1Mr=$(awk '{print $1/$2}' <<< "$slowAux1D1Mr $NumRep")
		slowD1Mw=$(awk '{print $1/$2}' <<< "$slowAux1D1Mw $NumRep")
		fastD1Mr=$(awk '{print $1/$2}' <<< "$fastAux1D1Mr $NumRep")
		fastD1Mw=$(awk '{print $1/$2}' <<< "$fastAux1D1Mw $NumRep")

		echo "$N $slowD1Mr	$slowD1Mw	$fastD1Mr	$fastD1Mw" >> cache_"$size".dat

		slowD1Mr=$(awk '{print $1/$2}' <<< "$slowAux2D1Mr $NumRep")
		slowD1Mw=$(awk '{print $1/$2}' <<< "$slowAux2D1Mw $NumRep")
		fastD1Mr=$(awk '{print $1/$2}' <<< "$fastAux2D1Mr $NumRep")
		fastD1Mw=$(awk '{print $1/$2}' <<< "$fastAux2D1Mw $NumRep")

		echo "$((N + NPaso)) $slowD1Mr	$slowD1Mw	$fastD1Mr	$fastD1Mw" >> cache_"$size".dat

	done
done


echo "Generando grafica con GNUPLOT..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"

# Generamos la gráfica para los errores en lectura de los
# programas slow y fast

gnuplot << END_GNUPLOT
set title "Slow-Fast Lectura"
set ylabel "Num Fallos"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "cache_lectura.png"
plot "cache_1024.dat" using 1:2 with lines lw 2 title "slow_1024", \
		 "cache_1024.dat" using 1:4 with lines lw 2 title "fast_1024", \
		 "cache_2048.dat" using 1:2 with lines lw 2 title "slow_2048", \
		 "cache_2048.dat" using 1:4 with lines lw 2 title "fast_2048", \
		 "cache_4096.dat" using 1:2 with lines lw 2 title "slow_4096", \
		 "cache_4096.dat" using 1:4 with lines lw 2 title "fast_4096", \
		 "cache_8192.dat" using 1:2 with lines lw 2 title "slow_8192", \
		 "cache_8192.dat" using 1:4 with lines lw 2 title "fast_8192"
replot
quit
END_GNUPLOT

# Generamos la gráfica para los errores en escritura de los
# programas slow y fast

gnuplot << END_GNUPLOT
set title "Slow-Fast Escritura"
set ylabel "Num Fallos"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "cache_escritura.png"
plot "cache_1024.dat" using 1:3 with lines lw 2 title "slow_1024", \
		 "cache_1024.dat" using 1:5 with lines lw 2 title "fast_1024", \
		 "cache_2048.dat" using 1:3 with lines lw 2 title "slow_2048", \
		 "cache_2048.dat" using 1:5 with lines lw 2 title "fast_2048", \
		 "cache_4096.dat" using 1:3 with lines lw 2 title "slow_4096", \
		 "cache_4096.dat" using 1:5 with lines lw 2 title "fast_4096", \
		 "cache_8192.dat" using 1:3 with lines lw 2 title "slow_8192", \
		 "cache_8192.dat" using 1:5 with lines lw 2 title "fast_8192"
replot
quit
END_GNUPLOT

echo "Hora de finalización de ejecución:"
date +"%T"
