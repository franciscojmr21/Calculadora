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
const char* tipoError[3]={};
//definición de procedimientos auxiliares

void errorDiv0(){         /*    llamada por cada error semántico de yacc */
	cout << "Error semántico en la instrucción "<< n_instruciones<<": división por cero"<<endl;	
} 
void errorDivInt(string op){         /*    llamada por cada error semántico de yacc */
	cout << "Error semántico en la instrucción "<< n_instruciones<<": se usa el operador "<<op<<" con operandos reales"<<endl;	
}
void errorVarNoDef(string var){         /*    llamada por cada error semántico de yacc */
	cout << "Error semántico en la instrucción "<< n_instruciones<<": la variable "<<var<<" no está definida"<<endl;	
} 
void errorVarIsInt(string var, const char* type){         /*    llamada por cada error semántico de yacc */
	cout << "Error semántico en la instrucción "<< n_instruciones<<": la variable "<<var<<" es de tipo ";
	if(strcmp(type, "0")==0){
		cout<<"entero y no se le puede asignar un valor real"<<endl;
	}else{
		cout<<"real y no se le puede asignar un valor entero"<<endl;
	}	
}

void yyerror(const char* s){         /*    llamada por cada error sintactico de yacc */
	cout << "ERRORRRRRRR "<<endl;
	if (strcmp(tipoError[0], "1") == 0){
		errorDiv0();
	} else if (strcmp(tipoError[0], "2") == 0){
		errorDivInt(tipoError[1]);
	} else if (strcmp(tipoError[0], "3") == 0){
		errorVarNoDef(tipoError[1]);
	} else if (strcmp(tipoError[0], "4") == 0){
		errorVarIsInt(tipoError[1], tipoError[2]);
	} else {
		cout << "Error sintáctico en la instrucción " << n_instruciones << endl;
	}
} 

void prompt(){
	n_instruciones++;
	cout<<"se incrementa +1"<<endl;
	cout<<endl<<"instruccion "<<n_instruciones<<endl;
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
linea:  IDENTIFICADOR ASIGNACION expr '\n' {	tipo_datoTS dato; tipo_datoTS datoID; cout<<"id prueba "<<$1<<endl;
						strcpy(datoID.identificador, $1);
						bool existe = obtenerDato(TS, datoID);
						cout<<"existe "<<existe<<endl;
						if($3.isInt){
							if(existe && datoID.tipo!=0){
								tipoError[0]="4";
								tipoError[1]=$1;
								tipoError[2]="0";
								yyerror;
							}else{
								strcpy(dato.identificador, $1);
								dato.tipo = 0;
								dato.valor.valor_entero = $3.valor;
							}
						}else{
							if(existe && datoID.tipo!=1){
								tipoError[0]="4";
								tipoError[1]=$1;
								tipoError[2]="1";
								yyerror;
							}else{
								strcpy(dato.identificador, $1);
								dato.tipo = 1;
								dato.valor.valor_real = $3.valor;
							}
						}
						insertar(TS, dato);
						prompt(); }
	| IDENTIFICADOR ASIGNACION logico '\n' {tipo_datoTS dato;
											strcpy(dato.identificador, $1);
											dato.tipo = 2;
											dato.valor.valor_bool = $3;
											insertar(TS, dato);
											prompt();}	
	|error		'\n'			{yyerror; prompt();}      
	;
	
       
logico: _TRUE		{$$=true;}
	|_FALSE	{$$=false;}
	|IDENTIFICADOR			{cout<<"id log "<<$1<<endl;
						tipo_datoTS dato;
						strcpy(dato.identificador, $1);
						error = !obtenerDato(TS, dato);
						if(error){ 
							tipoError[0]="3";
							tipoError[1]=$1;
							yyerror;
							cout<<"error id log"<<endl;}
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
	|expr IGUAL expr	{cout<<"igual expr"<<endl;$$ = $1.valor == $3.valor; }
	|expr DISTINTO expr	{$$ = $1.valor != $3.valor;}
	|logico IGUAL logico	{cout<<"igual log"<<endl;$$ = $1 == $3;}
	|logico DISTINTO logico {$$ = $1 != $3;}
	|logico AND logico {$$ = $1 && $3;}
	|logico OR logico {$$ = $1 || $3;}
	|NOT logico 		{if($2)$$=false;else $$=true;}
	|'(' logico ')'		{$$=$2;}
	;

expr:    NUMERO 		      {$$.isInt=true;$$.valor=$1;}   
	|REAL                   	{$$.isInt=false;$$.valor=$1;} 
	|IDENTIFICADOR			{cout<<"id expr "<<$1<<endl;
						tipo_datoTS dato;
						strcpy(dato.identificador, $1);
						error = !(obtenerDato(TS, dato));
						cout<<"2id prueba "<<$1<<endl;
						if(error) {
							tipoError[0]="3";
							tipoError[1]=$1;
							yyerror;
						}
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
       | expr '*' expr        {$$.isInt= $1.isInt && $3.isInt; $$.valor=$1.valor*$3.valor; cout<<"1prueba "<<endl;} 
       | expr '/' expr        {$$.isInt= false; if($3.valor != 0) 
				       				$$.valor=static_cast<double>($1.valor/$3.valor);
				       			else {
				       				yyerror;}
								} 
       | expr DIV expr        {$$.isInt = $1.isInt && $3.isInt; if($3.valor == 0) {
									tipoError[0]="1";
       								yyerror;
       								}
       							else{if($$.isInt) 
       								$$.valor=$1.valor/$3.valor;
       							if(!$$.isInt) {
									tipoError[0]="2";
									tipoError[1]="div";
       								yyerror; 
       								}
								}
       			} 
       								
       | expr '%' expr		{$$.isInt = $1.isInt && $3.isInt; if($3.valor == 0) {
									tipoError[0]="1";
       								yyerror;
       								}
       							else{
       								if($$.isInt) 
       									$$.valor=int($1.valor)%int($3.valor); 
	       							else {
										tipoError[0]="2";
										tipoError[1]="%";
										yyerror; }
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
