#!/bin/bash

#	Instalação:
#	chmod +x test.sh
#
#	Configuração:
#	Alterar o nome da turma
#
#	Modo de uso:
#	./test.sh nome do programa

code="$1"
turma="mc102wy"
i=1;

# O codigo \033 eh usado para dar um espaco 
# Colors
green="\033[32m"
red="\033[31m"
yellow="\033[33m"

# Tipo Letra
normal="\033[0m"
bold="\033[1m"

#Verifica se o numero de parametros esta correto
# o unico parametro que o programa deve receber eh o nome do programa
if [ ! $# -eq 1 ]; then
    echo "Numero de parametros incorretos, apenas o nome do laborarior (ex lab00x) eh necessario"
else
    # Retira a extensao do nome do arquivo caso o usuario tenha colocado
    # o codigo C ao inves do nome do programa
    code="${code%.*}"
    
    #Compila
    echo -e "$yellow Compilando codigo $normal"  
    $(gcc $code.c -o $code -lm)

    #Caso a compilacao tenha dado erro
    if [ ! $? -eq 0 ]; then
	#Sair do programa
	echo -e "$red ERROR  $normal"
	exit 1
    else
	#Caso contrario continuar com a execucao dos testes
	
	# Se o diretorio nao existe, baixe os arquivos e crie o diretorio
	if ( [ -d aux ] ); then
	    echo -e "$yellow W $normal Usando diretorio $yellow[aux]$normal local"
	else
	    echo -e "$yellow W $normal Baixando testes..."
	    read -p $'$yellow Q $normal Numero do lab (ex. 00x): ' nlab

	    # Cria o diretorio e baixa o zip
	    $(mkdir aux)
	    $(curl -silent -LOk https://susy.ic.unicamp.br:9999/$turma/$nlab/aux/testes.zip)

	    echo -e "$yellow W $normal Descompactando arquivos..."

	    # Descompacta os arquivos e deleta o zip
	    $(unzip -q testes.zip -d aux > /dev/null 2>&1)
	    $(rm testes.zip)

	fi

	# Para cada arquivo em aux com final .in

	echo -e "$red I $normal Rodando testes"

	for filename in $(pwd)/aux/*.in; do

	    # Retira a extensao do nome do arquivo
	    file="${filename%.*}"

	    # Itera pelos testes
	    printf "$yellow R $normal Teste $bold[%02d]$normal... " $i

	    # Cria a saida de acordo com a entrada
	    $(./$code < $file.in > $file.out)

	    # Compara com o resultado esperado e
	    # diz se o programa passou ou nao

	    $(diff $file.out $file.res > /tmp/thediff 2>&1)

	    if [ $? != 0 ] 
	    then
		echo -e "$red FAIL\n $normal $(cat /tmp/thediff)"
	    else
		echo -e "$green OK $normal"
	    fi

	    # Remove o arquivo de saida
	    $(rm $file.out)

	    # i += 1
	    i=`expr $i + 1`
	done
    fi
fi
