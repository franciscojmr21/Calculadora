%{
#include "expresiones.h"
#include <math.h>
int n_instruciones;
%}

asignacion [:][=]
div [d][i][v]
identificador [a-zA-Z_][a-zA-Z0-9_]*
entero [0-9]+
real {entero}[.]{entero}|[.]{entero}|{entero}[.]
cientifica {real}[eE][+-]?{entero}
true [tT][rR][uU][eE]
false [Ff][Aa][Ll][Ss][Ee]
igual [=][=]
distinto [!][=]
and [a][n][d]
or [o][r]
not [n][o][t]


%option noyywrap
%x COM1
 
%%

"//"         BEGIN(COM1);
<COM1>"\n"     BEGIN(0);
<COM1>.     ;

SALIR			return SALIR;
{true}			return _TRUE;
{false}		return _FALSE;
{igual}		return IGUAL;
{distinto}		return DISTINTO;
{and}			return AND;
{or}			return OR;
{not}			return NOT;
{asignacion}			return ASIGNACION;
{div}				return DIV;
{entero}			yylval.c_entero = atoi(yytext);return NUMERO;
{real}|{cientifica}		yylval.c_real = strtod(yytext, NULL);return REAL;
[<]				return LOGICOMENOR;
[<][=]				return LOGICOMENORIGUAL;
[>][=]				return LOGICOMAYORIGUAL;
[>]				return LOGICOMAYOR;
\n				return (yytext[0]);
[\t ]			;	
{identificador}	strcpy(yylval.c_cadena, yytext);return IDENTIFICADOR;
. 				return (yytext[0]);
%%


