#include "Tabla.h"
#include <string>
#include <iostream>


using namespace std;

extern FILE *f;

void insertar (tabla_IDs &TS, tipo_datoTS dato){
	int pos = 0;
	if(buscar(TS, dato.identificador, pos)){
		insertarDatos(TS, dato, pos);
	
	}else{
		if(insertados<100){
			insertarDatos(TS, dato, insertados);
			insertados++;
		}
	}
}

bool buscar (tabla_IDs TS, tipo_cadena nombre, int &pos){
	
	int i = 0;
	bool enc = false;
	while(i<insertados && !enc){
		if(strcmp(TS[i].identificador, nombre)==0){
			enc = true;
			pos = i;
		}
		i++;
	}
	return enc;

}



void insertarDatos(tabla_IDs &TS, tipo_datoTS dato, int pos){
	
	switch (dato.tipo) {
		case 0:
			TS[pos].tipo = 0;
			TS[pos].valor.valor_entero = dato.valor.valor_entero;
		    break;
		case 1:
			TS[pos].tipo = 1;
			TS[pos].valor.valor_real = dato.valor.valor_real;
		    break;
		case 2:
			TS[pos].tipo = 2;
			TS[pos].valor.valor_bool = dato.valor.valor_bool;
		    break;
		case 3:
			TS[pos].tipo = 3;
			strcpy(TS[pos].valor.valor_cad, dato.valor.valor_cad);
		    break;
	}
	strcpy(TS[pos].identificador, dato.identificador);

}

void mostrarTS(tabla_IDs TS){
	if(insertados>0){
		cout<<"Tabla de símbolos:"<<endl;
		for(int i = 0; i<insertados; i++){;
			cout<<TS[i].identificador<<"	";
			switch (TS[i].tipo) {
				case 0:
					cout<<"entero	"<<TS[i].valor.valor_entero<<endl;
				    break;
				case 1:
					cout<<"real	"<<TS[i].valor.valor_real<<endl;
				    break;
				case 2:
					cout<<"lógico	";
					if(TS[i].valor.valor_bool == 1){
						cout<<"true"<<endl;
					}
					else{
						cout<<"false"<<endl;
					}
				    break;
				case 3:
					cout<<"cadena	"<<TS[i].valor.valor_cad<<endl;
				    break;
		    	}
	    	}
    	}
}

bool obtenerDato(tabla_IDs TS, tipo_datoTS &dato){
	int pos = 0;
	bool enc = buscar (TS, dato.identificador, pos);
	if(enc){
		
		dato.tipo = TS[pos].tipo;
		switch (TS[pos].tipo) {
		
			case 0:
				dato.valor.valor_entero = TS[pos].valor.valor_entero;
			    break;
			case 1:
				dato.valor.valor_real = TS[pos].valor.valor_real;
			    break;
			case 2:
				dato.valor.valor_bool = TS[pos].valor.valor_bool;
			    break;
			case 3:
				strcpy(dato.valor.valor_cad, TS[pos].valor.valor_cad);
			    break;
		}
	}
	
	return enc;

}



