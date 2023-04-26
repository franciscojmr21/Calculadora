%{
#include <iostream>
#include "Tabla.h"

using namespace std;

//elementos externos al analizador sintácticos por haber sido declarados en el analizador léxico      			
extern int n_instruciones;
extern int yylex();
extern FILE* yyin;
extern FILE* yyout;
bool isInt = false;
bool error = false;
bool c_logico = false;
tabla_IDs TS;

//definición de procedimientos auxiliares
void yyerror(const char* s){         /*    llamada por cada error sintactico de yacc */

	cout << "Error sintáctico en la instrucción "<< n_instruciones<<endl;
	error=false; 	
} 
void errorDiv0(){         /*    llamada por cada error semántico de yacc */
	cout << "Error semántico en la instrucción "<< n_instruciones<<": división por cero"<<endl;	
} 
void errorDivInt(string op){         /*    llamada por cada error semántico de yacc */
	cout << "Error semántico en la instrucción "<< n_instruciones<<": se usa el operador "<<op<<" con operandos reales"<<endl;	
}
void errorVarNoDef(string var){         /*    llamada por cada error semántico de yacc */
	cout << "Error semántico en la instrucción "<< n_instruciones<<": la variable "<<var<<" no está definida"<<endl;	
} 

void prompt(){
	n_instruciones++;
}

%}

%start entrada
%token NUMERO SALIR IDENTIFICADOR REAL ASIGNACION DIV LOGICOMAYOR LOGICOMENOR LOGICOMAYORIGUAL LOGICOMENORIGUAL _TRUE _FALSE IGUAL DISTINTO AND OR NOT
%type <c_expresion> expr
%type <c_cadena> IDENTIFICADOR
%type <c_entero> NUMERO
%type <c_real> REAL
%type <c_logico> logico

%left OR
%left AND
%left IGUAL DISTINTO
%left MENOR MENORIGUAL MAYORIGUAL MAYOR
%left '+' '-'   /* asociativo por la izquierda, misma prioridad */
%left '*' '/' DIV '%' /* asociativo por la izquierda, prioridad alta */
%left menos
%left NOT

%union{
	int c_entero;
	char c_cadena[25];
	double c_real;
	bool c_logico;
	struct {
		float valor;
		bool isInt;
	} c_expresion;
}

%%


entrada: 		{prompt();}
      |entrada linea
      ;
linea:  IDENTIFICADOR ASIGNACION expr '\n' {	tipo_datoTS dato;
						if(!error){
							if($3.isInt){
								strcpy(dato.identificador, $1);
								dato.tipo = 0;
								dato.valor.valor_entero = $3.valor;
							}else{
								strcpy(dato.identificador, $1);
								dato.tipo = 1;
								dato.valor.valor_real = $3.valor;
							}
							insertar(TS, dato);
						}
						else error=false; 
						prompt(); }
	| IDENTIFICADOR ASIGNACION logico '\n' {tipo_datoTS dato;
											if(!error) {

												strcpy(dato.identificador, $1);
												dato.tipo = 2;
												dato.valor.valor_bool = $3;
												insertar(TS, dato);
											}
											else error=false; 
											prompt();}	
	|error		'\n'			{yyerrok;prompt();}      
	;
	
       
logico: _TRUE		{$$=true;}
	|_FALSE	{$$=false;}
	|IDENTIFICADOR			{
						tipo_datoTS dato;
						strcpy(dato.identificador, $1);
						error = obtenerDato(TS, dato);
						if(error) errorVarNoDef($1);
						else{
							switch (dato.tipo) {
								case 0:
									cout<<"error, no puede ser de tipo numerico"<<endl;
								    break;
								case 1:
									cout<<"error, no puede ser de tipo numerico"<<endl;
								    break;
								case 2:
									$$ = dato.valor.valor_bool;
								    break;
							}
						}
					} 
	|expr LOGICOMAYOR expr	{$$ = $1.valor>$3.valor;}
	|expr LOGICOMENOR expr	{$$ = $1.valor<$3.valor;}
	|expr LOGICOMAYORIGUAL expr	{$$ = $1.valor>=$3.valor;}
	|expr LOGICOMENORIGUAL expr	{$$ = $1.valor<=$3.valor;}
	|expr IGUAL expr	{$$ = $1.valor == $3.valor;}
	|expr DISTINTO expr	{$$ = $1.valor != $3.valor;}
	|logico IGUAL logico	{$$ = $1 == $3;}
	|logico DISTINTO logico {$$ = $1 != $3;}
	|logico AND logico {$$ = $1 && $3;}
	|logico OR logico {$$ = $1 || $3;}
	|NOT logico 		{if($2)$$=false;else $$=true;}
	|'(' logico ')'		{$$=$2;}
	;

expr:    NUMERO 		      {$$.isInt=true;$$.valor=$1;}   
	|REAL                   	{$$.isInt=false;$$.valor=$1;} 
	|IDENTIFICADOR			{
						tipo_datoTS dato;
						strcpy(dato.identificador, $1);
						error = !(obtenerDato(TS, dato));
						if(error) errorVarNoDef($1);
						else{
							switch (dato.tipo) {
								case 0:
									$$.isInt = true;
									$$.valor = dato.valor.valor_entero;
								    break;
								case 1:
									$$.isInt=false;
									$$.valor = dato.valor.valor_real;
								    break;
								case 2:
									cout<<"error, no puede ser de tipo logico"<<endl;
								    break;
							}
						}
					}  
       | expr '+' expr 		{$$.isInt= $1.isInt && $3.isInt;$$.valor=$1.valor+$3.valor;}              
       | expr '-' expr    	{$$.isInt= $1.isInt && $3.isInt; $$.valor=$1.valor-$3.valor;}            
       | expr '*' expr        {$$.isInt= $1.isInt && $3.isInt; $$.valor=$1.valor*$3.valor;} 
       | expr '/' expr        {$$.isInt= false; if($3.valor != 0) 
				       				$$.valor=static_cast<double>($1.valor/$3.valor);
				       			else {
				       				error=true;  
				       				errorDiv0();}
								} 
       | expr DIV expr        {$$.isInt = $1.isInt && $3.isInt; if($3.valor == 0) {
       								error=true; 
       								errorDiv0();
       								}
       							else{if($$.isInt) 
       								$$.valor=$1.valor/$3.valor;
       							if(!$$.isInt) {
       								error=true; 
       								errorDivInt("div"); 
       								}
								}
       			} 
       								
       | expr '%' expr		{$$.isInt = $1.isInt && $3.isInt; if($3.valor == 0) {
       								error=true; 
       								errorDiv0();
       								}
       							else{
       								if($$.isInt) 
       									$$.valor=int($1.valor)%int($3.valor); 
	       							else {
	       								error=true;
	       								errorDivInt("%");}
	       							}
	       						}
       |'-' expr %prec menos  {$$.valor= -$2.valor;$$.isInt = $2.isInt;}
       |'(' expr ')'		{$$.valor=$2.valor; $$.isInt = $2.isInt;}
       ;



%%


int main(int argc, char *argv[]){
     
     n_instruciones = 0;
     
     cout <<endl<<"******************************************************"<<endl;
     cout <<"*      Calculadora de expresiones aritméticas        *"<<endl;
     cout <<"*                                                    *"<<endl;
     cout <<"*      1)con el prompt LISTO>                        *"<<endl;
     cout <<"*        teclea una expresión, por ej. 1+2<ENTER>    *"<<endl;
     cout <<"*        Este programa indicará                      *"<<endl;
     cout <<"*        si es gramaticalmente correcto              *"<<endl;
     cout <<"*      2)para terminar el programa                   *"<<endl;
     cout <<"*        teclear SALIR<ENTER>                        *"<<endl;
     cout <<"*      3)si se comete algun error en la expresión    *"<<endl;
     cout <<"*        se mostrará un mensaje y la ejecución       *"<<endl;
     cout <<"*        del programa finaliza                       *"<<endl;
     cout <<"******************************************************"<<endl<<endl<<endl;
	 if(argc > 2){
		yyin = fopen(argv[1], "r");
		yyout = fopen(argv[2], "w");
     	yyparse();
		mostrarTS(TS);
	 }else{
		cout << "Error en los argumentos" << endl;
	 }

	 fclose(yyin);
	
     cout <<"****************************************************"<<endl;
     cout <<"*                                                  *"<<endl;
     cout <<"*                 ADIOS!!!!                        *"<<endl;
     cout <<"****************************************************"<<endl;
     return 0;
}
