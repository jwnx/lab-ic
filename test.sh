#!/bin/bash

#
# Os arquivos de teste devem ser descompactados
# na pasta chamada "aux" que esta dentro da pasta
# que contem o codigo compilado.
#
# Ex: /home/cc2015/ra666666/codigos/00-baby-steps/aux
#     /home/cc2015/ra666666/codigos/00-baby-steps/lab00
#
# Ou voce pode simplesmente mudar o nome da pasta 
# no codigo...
#


code="$1"

#novo modo de uso: ./test.sh nome_do_programa turma id_do_lab numero_de_testes
turma="$2"
lab="$3"
numeroTestes="$4"

i=0;

if ( [ -d aux ] ); then
	echo "usando testes antigos da pasta aux"
else
	echo "baixando testes"
	$(mkdir aux)
	while [ $i -lt $numeroTestes ]; do
		#baixa testes, usando -k por causa dos certificados quebrados do IC
		$(curl -k https://susy.ic.unicamp.br:9999/$turma/$lab/dados/arq$i.in > aux/arq$i.in)
		$(curl -k https://susy.ic.unicamp.br:9999/$turma/$lab/dados/arq$i.res > aux/arq$i.res)
		let i=i+1
	done
fi


i=0;

# Compila
$(gcc $code.c -o $code)

# Para cada arquivo em aux com final .in
for filename in $(pwd)/aux/*.in; do

	# Retira a extensao do nome do arquivo
	file="${filename%.*}"

	# Itera pelos testes
	printf "\033[33m[ RUN ] \033[0m Teste %02d... " $i

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
