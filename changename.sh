#!/bin/bash
OPTIONS=$(getopt -o n:,r,f --long force,help,newname:,reboot -n 'parse-options' -- "$@")

bold=$(tput bold)
regular=$(tput sgr0)
rebootflag=false
forceflag=false
regexhostname='^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$'


#COMPRUEBA SI ES EJECUTADO CON PRIVILEGIOS
if [ "$EUID" != 0 ]; then
	echo "$0: (1) Es necesario ejecutar este script como administrador"
	exit 1
fi

#COMPRUEBA QUE TENGA ARGUMENTOS
if [ -z "$1" ]; then
	echo -e "$0: (2) falta un operando\n Pruebe '$0 --help' para más información."
	exit 2
fi

#COMPRUEBA SI SE HA SOLICITADO LA AYUDA
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]];then
	echo "
	changename [OPTIONS...] [ARG] or changename newname

	${bold}Cambia el nombre del sistema.${regular}

	Opciones:
  		-h  --help	 Muestra esta ayuda
  		-n  --newname	 Establece el nuevo nombre de máquina
  		-f  --force	 Cambia el nombre sin confirmar
  		-r  --reboot	 Reinicia el sistema tras el cambio sin confirmar
  	"
  	exit
fi

#SI SOLO HAY UN PARAMETRO, LO ESTABLECE COMO NUEVO NOMBRE DE HOST
if [[ "$#" == 1  ]]; then
	newname="$1"
fi

#FUNCION DE REINICIO
reboot (){
	if [[ "$rebootflag" == false ]]; then
		echo -e "Es necesario reinciar para hacer efectivo el cambio de nombre.\n ${bold}Reiniciar ahora? (s\\\n)${regular}"
		read reiniciar
	else
		reiniciar="s"
	fi
	if [[ "$reiniciar" == "s" ]];then
		/sbin/reboot
	fi
}

#FUNCION DE CAMBIADO DE NOMBRE
cambiarnombre (){
	if [[ ! $(echo "$newname" | grep -E "$regexhostname")  ]];then
		echo "$0: (3) El nombre escogido para el host no es valido."
		exit 3
	fi
	if [[ "$forceflag" == false ]];then
		echo -e "Se cambiará el hostname actual ${bold}`hostname`${regular} por ${bold}$1${regular}. ¿Proceder con el cambio? (s\\\n)"
		read efectuarcambio
	else
		efectuarcambio="s"
	fi

	if [[ "$efectuarcambio" == "s" ]];then
		sed -i "/127.0.1.1/c\127.0.1.1 $1" /etc/hosts
		echo $1 > /etc/hostname
		echo -e "${bold}Nombre cambiado con éxito!${regular}"
		x=""
	else
		echo "$0: El nombre no fue cambiado"
		exit 1
	fi
}

if [ $# -gt 1 ]; then
	eval set -- "$OPTIONS"

	while true; do
		case "$1" in
			-n | --newname )
				newname="$2" ; shift 2;;
			-r | --reboot )
				rebootflag=true ; shift ;;
			-f | --force )
				forceflag=true; shift ;;
			-- )
				shift ; break ;;
			* )
				break ;;
		esac
	done
fi

cambiarnombre $newname
reboot
