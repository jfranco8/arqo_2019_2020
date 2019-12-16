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

# Inicializar variables
N1=1000
N2=2000
NumRep=3

# borrar los ficheros DAT y el fichero PNG
rm -f e3_1.dat e3_2.dat e3_3.dat e3_4.dat e3_aceleracion_1.dat e3_aceleracion_2.dat e3_aceleracion_3.dat e3_aceleracion_4.dat

# Generamos los ficheros vacios
touch e3_1.dat e3_2.dat e3_3.dat e3_4.dat e3_aceleracion_1.dat e3_aceleracion_2.dat e3_aceleracion_3.dat e3_aceleracion_4.dat


echo ""
echo "------------------------------------------"
echo "| Practica 4 Arquitectura de Ordenadores |"
echo "| Grupo 1301 Pareja 37                   |"
echo "| Jesus Daniel Franco Lopez              |"
echo "| Santiago Manuel Valderrabano Zamorano  |"
echo "------------------------------------------"
echo ""
echo "Comienza a ejecutar a las:"
date +"%T"
echo ""
echo "Ejecutando ejercicio 3..."

for((hilo = 1; hilo<=4; hilo++));do
echo "Hilo $hilo / 4..."

	if((hilo==1)); then
		normalTime1=0
		normalTime2=0
	else
		normalTime1=$(awk -v var="$N1" '{if ($1 == var) print $2}' e3_1.dat)
		normalTime2=$(awk -v var="$N2" '{if ($1 == var) print $2}' e3_1.dat)
	fi

	normalTimePar1_1=0
	normalTimePar2_1=0
	normalTimePar3_1=0
	normalTimePar1_2=0
	normalTimePar2_2=0
	normalTimePar3_2=0

	for ((i = 0; i < NumRep; i++)); do
		if((hilo==1)); then
			normalTime1=$(awk '{print $1+$2}' <<< "$normalTime1 $(./multNormal $N1 | grep 'time' | awk '{print $3}')")
			normalTime2=$(awk '{print $1+$2}' <<< "$normalTime2 $(./multNormal $N2 | grep 'time' | awk '{print $3}')")
		fi
		normalTimePar1_1=$(awk '{print $1+$2}' <<< "$normalTimePar1_1 $(./multNormal_par1 $N1 $hilo | grep 'time' | awk '{print $3}')")
		normalTimePar2_1=$(awk '{print $1+$2}' <<< "$normalTimePar2_1 $(./multNormal_par2 $N1 $hilo | grep 'time' | awk '{print $3}')")
		normalTimePar3_1=$(awk '{print $1+$2}' <<< "$normalTimePar3_1 $(./multNormal_par3 $N1 $hilo | grep 'time' | awk '{print $3}')")
		normalTimePar1_2=$(awk '{print $1+$2}' <<< "$normalTimePar1_2 $(./multNormal_par1 $N2 $hilo | grep 'time' | awk '{print $3}')")
		normalTimePar2_2=$(awk '{print $1+$2}' <<< "$normalTimePar2_2 $(./multNormal_par2 $N2 $hilo | grep 'time' | awk '{print $3}')")
		normalTimePar3_2=$(awk '{print $1+$2}' <<< "$normalTimePar3_2 $(./multNormal_par3 $N2 $hilo | grep 'time' | awk '{print $3}')")
	done

	normalAc=$(awk '{print $1/$2}' <<< "$normalTime1 $normalTime1")
	normalAcPar1=$(awk '{print $1/$2}' <<< "$normalTime1 $normalTimePar1_1")
	normalAcPar2=$(awk '{print $1/$2}' <<< "$normalTime1 $normalTimePar2_1")
	normalAcPar3=$(awk '{print $1/$2}' <<< "$normalTime1 $normalTimePar3_1")

	echo "$N1 $normalAc $normalAcPar1 $normalAcPar2 $normalAcPar3" >> e3_aceleracion_"$hilo".dat

	normalTime=$(awk '{print $1/$2}' <<< "$normalTime1 $NumRep")
	normalTimePar1=$(awk '{print $1/$2}' <<< "$normalTimePar1_1 $NumRep")
	normalTimePar2=$(awk '{print $1/$2}' <<< "$normalTimePar2_1 $NumRep")
	normalTimePar3=$(awk '{print $1/$2}' <<< "$normalTimePar3_1 $NumRep")

	echo "$N1 $normalTime $normalTimePar1 $normalTimePar2 $normalTimePar3" >> e3_"$hilo".dat

	normalAc=$(awk '{print $1/$2}' <<< "$normalTime2 $normalTime2")
	normalAcPar1=$(awk '{print $1/$2}' <<< "$normalTime2 $normalTimePar1_2")
	normalAcPar2=$(awk '{print $1/$2}' <<< "$normalTime2 $normalTimePar2_2")
	normalAcPar3=$(awk '{print $1/$2}' <<< "$normalTime2 $normalTimePar3_2")

	echo "$N2 $normalAc $normalAcPar1 $normalAcPar2 $normalAcPar3" >> e3_aceleracion_"$hilo".dat

	normalTime=$(awk '{print $1/$2}' <<< "$normalTime2 $NumRep")
	normalTimePar1=$(awk '{print $1/$2}' <<< "$normalTimePar1_2 $NumRep")
	normalTimePar2=$(awk '{print $1/$2}' <<< "$normalTimePar2_2 $NumRep")
	normalTimePar3=$(awk '{print $1/$2}' <<< "$normalTimePar3_2 $NumRep")

	echo "$N2 $normalTime $normalTimePar1 $normalTimePar2 $normalTimePar3" >> e3_"$hilo".dat

done
