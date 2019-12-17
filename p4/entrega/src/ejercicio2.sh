#!/bin/bash

make clean
make
clear

#inicializamos variables

echo "Hora de comienzo de ejecución:"
date +"%T"
echo ""
echo "Ejecutando ejercicio 2..."

min=50000000
max=900000000
npaso=(max-min)/10
numrep=5

#borramos los ficheros
rm -f e2_1.dat e2_2.dat e2_3.dat e2_4.dat e2_aceleracion_1.dat e2_aceleracion_2.dat e2_aceleracion_3.dat e2_aceleracion_4.dat e2.png e2_aceleracion.png
#creamos ficheros vacíos
touch e2_1.dat e2_2.dat e2_3.dat e2_4.dat e2_aceleracion_1.dat e2_aceleracion_2.dat e2_aceleracion_3.dat e2_aceleracion_4.dat

for((j=1; j<=4; j++)); do
  #tenemos 4 cores fisicos
	echo "Hilo $j/4"
	for((k=min; k<=max; k+=npaso)); do
  paralelo=0
	   echo "$k/$max"
     if((j==1)); then
       serie=0
     else
       serie=$(awk -v var="$k" '{if ($1 == var) print $2}' e2_1.dat)
     fi
     #el producto escalar en serie lo ejecutamos solo una vez
     for ((i=1 ; i<=numrep ; i++)); do
       if((j==1)); then
         serie_aux=$(./pescalar_serie $k |grep 'Tiempo:' | awk ' {print $2}')
         serie=$(awk '{print $1+$2}' <<< "$serie $serie_aux")
       fi
       #el paralelo se ejecuta una vez para cada numero de hilos
       paralelo_aux=$(./pescalar_par2 $k $j |grep 'Tiempo:' | awk ' {print $2}')
       paralelo=$(awk '{print $1+$2}' <<< "$paralelo $paralelo_aux")

    done

		if((j==1)); then
    	serie=$(awk '{print $1/$2}' <<< "$serie $numrep")
		fi
    paralelo=$(awk '{print $1/$2}' <<< "$paralelo $numrep")
    echo "$k	$serie	$paralelo" >> e2_"$j".dat
    paralelo_aceleracion=$(awk '{print $1/$2}' <<< "$serie $paralelo")
    echo "$k $paralelo_aceleracion" >> e2_aceleracion_"$j".dat
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
set output "e2.png"
plot "e2_1.dat" using 1:2 with lines lw 2 title "serie", \
     "e2_1.dat" using 1:3 with lines lw 2 title "Hilo 1", \
     "e2_2.dat" using 1:3 with lines lw 2 title "Hilo 2", \
     "e2_3.dat" using 1:3 with lines lw 2 title "Hilo 3", \
     "e2_4.dat" using 1:3 with lines lw 2 title "Hilo 4"
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
set output "e2_aceleracion.png"
plot "e2_aceleracion_1.dat" using 1:2 with lines lw 2 title "Hilo 1", \
     "e2_aceleracion_2.dat" using 1:2 with lines lw 2 title "Hilo 2", \
     "e2_aceleracion_3.dat" using 1:2 with lines lw 2 title "Hilo 3", \
     "e2_aceleracion_4.dat" using 1:2 with lines lw 2 title "Hilo 4"
replot
quit
END_GNUPLOT
