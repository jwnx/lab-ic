#!/bin/bash

#	Instalação:
#	chmod +x test.sh
#
#	Configuração:
#	Alterar o nome da turma
#
#	Modo de uso:
#	./test.sh nome_do_programa


code="$1"
turma="mc102wy"

i=1;

# Se o diretorio nao existe, baixe os arquivos e crie o diretorio

if ( [ -d aux ] ); then
	echo -e "\033[33m W \033[0m Usando diretorio \033[33maux\033[0m local"
else
	echo -e "\033[33m W \033[0m Baixando testes..."
	read -p $'\033[33m Q \033[0m Numero do lab (ex. 00): ' nlab

	# Cria o diretorio e baixa o zip
	$(mkdir aux)
	$(curl -silent -LOk https://susy.ic.unicamp.br:9999/$turma/$nlab/aux/testes.zip)

	echo -e "\033[33m W \033[0m Descompactando arquivos..."

	# Descompacta os arquivos e deleta o zip
	$(unzip -q testes.zip -d aux > /dev/null 2>&1)
	$(rm testes.zip)

fi


# Compila
$(gcc $code.c -o $code)

# Para cada arquivo em aux com final .in

echo -e "\033[31m I \033[0m Rodando testes"

for filename in $(pwd)/aux/*.in; do

	# Retira a extensao do nome do arquivo
	file="${filename%.*}"

	# Itera pelos testes
	printf "\033[33m R \033[0m Teste \033[33m%02d\033[0m... " $i

	# Cria a saida de acordo com a entrada
	$(./$code < $file.in > $file.out)

	# Compara com o resultado esperado e
	# diz se o programa passou ou nao

	$(diff $file.out $file.res > /tmp/thediff 2>&1)

	if [ $? != 0 ] 
	then
		echo -e "\033[31m FAIL\n \033[0m $(cat /tmp/thediff)"
	else
		echo -e "\033[32m OK"
	fi

	# Remove o arquivo de saida
	$(rm $file.out)

	# i += 1
	i=`expr $i + 1`
done
