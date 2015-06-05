# lab-ic

Shell script criado para testes de algorítmos do laboratório de MC102. Cria-se um diretório **aux** e o preenche com os arquivos de testes do [**SUSY**](http://www.ic.unicamp.br/~susy/).

## Instalação:
~~~
	chmod +x test.sh
~~~

## Configuração:
   
Alterar o nome da turma em 
~~~
	turma="mc102wy" 
~~~

## Modo de uso:
~~~
   ./test.sh -[vh] <nome_do_programa> <número_do_teste>
~~~
As opções disponíveis são **-v**, roda o valgrind no código, e **-h** mostra o texto de ajuda. O **nome_do_programa** é obrigatório. O parâmetro **número_do_teste** é opcional e, caso deixado em branco, rodará todos os testes disponíveis.

## Exemplo:

~~~
   ./test.sh tchonsky 4     #roda o teste 4
   ./test.sh tchonsky       #roda todos os testes
   ./test.sh -v tchonsky    #roda todos com valgrind
~~~
##Licença

Este programa é um software livre; você pode redistribuí-lo e/ou modificá-lo dentro dos termos da **GPLv3** (http://www.gnu.org/licenses).


