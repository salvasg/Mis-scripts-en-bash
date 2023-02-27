#!/bin/bash

##SCRIPT PARA BORRADO SEGURO DE DISCOS USANDO 3 PASADAS UTILIZANDO shred –vfn 3 –vfz /dev/sd*

#COMPRUEBA SI ES EJECUTADO CON PRIVILEGIOS
if [ "$EUID" != 0 ]; then
	echo "$0: (1) Es necesario ejecutar este script como administrador"
	exit 1
fi

pregunta (){
echo ¿Cual de estos discos quieres eliminar?
echo `ls -l /dev/disk/by-id/ | awk '!/part/' | awk '!/usb/' | awk '{print $9, $11}' | sed 's/..\/..\//\/dev\//'`
read disco
}
