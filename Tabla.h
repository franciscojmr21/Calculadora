#include <string>
#include <cstring>
#include <iostream>

using namespace std;

typedef char tipo_cadena[25];

union tipo_valor{
	int		valor_entero;
	float		valor_real;
	bool		valor_bool;
	tipo_cadena	valor_cad;
};
struct tipo_datoTS{
	tipo_cadena	identificador;
	int		tipo;
	tipo_valor	valor;
};


typedef tipo_datoTS tabla_IDs[100];
static int insertados = 0;

void insertar (tabla_IDs &TS, tipo_datoTS dato);
bool buscar (tabla_IDs TS, tipo_cadena nombre, int &pos);
void insertarDatos(tabla_IDs &TS, tipo_datoTS dato, int pos);
void mostrarTS(tabla_IDs TS);
bool obtenerDato(tabla_IDs TS, tipo_datoTS &dato);
