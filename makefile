#fichero Makefile
#Autores: Pablo Rodríguez Rico y Francisco Javier Muñoz Ruiz

OBJ = expresiones.o lexico.o Tabla.o

expresiones : $(OBJ)     				#segunda fase de la traducción. Generación del código ejecutable 
	g++ -oexpresiones $(OBJ)
	./expresiones entrada.txt salida.txt
	
Tabla.o : Tabla.cpp
	g++ -c Tabla.cpp

expresiones.o : expresiones.c        	#primera fase de la traducción del analizador sintáctico
	g++ -c -oexpresiones.o  expresiones.c 
	
lexico.o : lex.yy.c						#primera fase de la traducción del analizador léxico
	g++ -c -olexico.o  lex.yy.c 	

expresiones.c : expresiones.y       	#obtenemos el analizador sintáctico en C
	bison -d -v -oexpresiones.c expresiones.y

lex.yy.c: lexico.l						#obtenemos el analizador léxico en C
	flex lexico.l

clean : 
	rm  -f  *.c *.o 
