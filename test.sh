#!/bin/bash

#	Instalação:
#	chmod +x test.sh
#
#	Configuração:
#	Alterar o nome da turma
#
#	Modo de uso:
#	./test.sh nome_do_programa
#       ./test.sh nome_do_programa teste_a_ser_executado

code="$1"
teste="$2"
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

# $1 : codigo a ser executado
# $2 : arquivo teste
# $3 : numero do teste
function executaTeste {
    # Itera pelos testes
    printf "$yellow R $normal Teste $bold[%02d]$normal... " $((10#$3))

    # Timestamp do UNIX concatenado em nanosegundos
    T="$(date +%s%N)"
    
    # Cria a saida de acordo com a entrada
    $(./$1 < $2.in > $2.out)

    # Cria a saida de acordo com a entrada, checando os acessos de memoria
    $(valgrind --leak-check=full ./$1 < $2.in > $2.out)

    # Intervalo de tempo em nanosegundos
    T="$(($(date +%s%N)-T))"

    #Intervalo de tempo em milisegundos
    M="$(echo "scale=3;$T/1000000" | bc)"

    # Compara com o resultado esperado e
    # diz se o programa passou ou nao

    $(diff $2.out $2.res > ./.thediff 2>&1)

    if [ $? != 0 ]
    then
	echo -e "$red FAIL\n $normal $(cat ./.thediff)"
    else
	echo -e "$green OK $normal ($M ms)"
    fi

    # Remove o arquivo de saida
    $(rm $2.out)
}

#Verifica se o numero de parametros esta correto
if [ $# -gt 2 ]; then
    echo -e "$red E $normal Número de parametros incorreto"
    echo -e "$red E $yellow ./test.sh <nome-do-arquivo> <numero-do-teste>"
    echo -e "$red E $normal O número do teste é opcional."
else
    # Verifica se o nome do laboratorio foi passado
    if [ -z $1 ]; then
    	#Sair do programa
    	echo -e "$red E $normal Parametros não foram passados."
        echo -e "$red E $yellow ./test.sh <nome-do-arquivo> <numero-do-teste>"
        echo -e "$red E $normal O número do teste é opcional."
    	exit 1

    else
    	# Retira a extensao do nome do arquivo caso o usuario tenha colocado
    	# o codigo C ao inves do nome do programa
    	code="${code%.*}"

    	# Remove os acentos do arquivo
    	acentos='y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/'
    	$(sed $acentos <$code.c> $code.tmp)

    	# Salva somente se os arquivos forem diferentes
    	$(cmp $code.c $code.tmp || mv $code.tmp $code.c)
	if [ -f $code.tmp ]; then
	    $(rm $code.tmp)
	fi

	#Compila
	echo -e "$yellow Compilando codigo $normal"
	$(gcc -ansi $code.c -o $code -lm)


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
    		read -p $'\e[33m Q \e[0m Numero do lab (ex. 00x): ' nlab

    		# Cria o diretorio e baixa o zip
    		$(mkdir aux)
    		$(curl -silent -LOk https://susy.ic.unicamp.br:9999/$turma/$nlab/aux/testes.zip)

    		echo -e "$yellow W $normal Descompactando arquivos..."

    		# Descompacta os arquivos e deleta o zip
    		$(unzip -q testes.zip -d aux > /dev/null 2>&1)
    		$(rm testes.zip)

	    fi


	    echo -e "$red I $normal Rodando testes"

        # Se o numero do teste a ser executado foi passado
	    if [ ! -z $2 ]; then
    		# Remove os 0's a esquerda do numero, para que 001 e 01 sejam iguais a 1
    		teste=$(echo $teste | sed 's/^0*//')

        # Se o numero do teste nao for valido
		if [ $teste -gt 10 ]; then
		    echo -e "$red E $normal O teste $red$teste$normal não é um teste válido"
            #Sai do programa
		    exit 1
		fi

		#formata o parametro para ter formato (00)
		while [[ $(echo -n ${teste} | wc -c) -lt 2 ]] ; do
		    teste="0${teste}"
		done

		filename=$(pwd)/aux/arq$teste.in;
		file="${filename%.*}"

		#Executa funcao
		executaTeste $code $file $teste

	    else
		# Para cada arquivo em aux com final .in
    		for filename in $(pwd)/aux/*.in; do

    		    # Retira a extensao do nome do arquivo
    		    file="${filename%.*}"

    		    # Executa funcao
    		    executaTeste $code $file $i

    		    # i += 1
    		    i=`expr $i + 1`
    		done
	    fi
	fi

	# Remove o arquivo temporario
	$(rm ./.thediff)
    fi
fi
