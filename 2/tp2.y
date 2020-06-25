%{
int yylex();
int yyerror(char* s);
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

%}

%token TITLE valor chave string NEWLINE NEWLINE2 ASPA IGUAL APAR FPAR VIRG

%%

Toml: TITLE IGUAL Aspas NEWLINE2 Blocos
    ;

Blocos: Blocos NEWLINE2 Bloco
    | 
    ;

Bloco: TagBloco NEWLINE ElsBloco NEWLINE2
    ;

ElsBloco: ElsBloco NEWLINE ElemBloco
    | ElemBloco
    ;

ElemBloco: ChaveValor
    | Bloco 
    ;

TagBloco: APAR chave FPAR
    ;

ChaveValor: chave IGUAL Valor
    ;

Valor: Aspas 
    | valor 
    | Array
    ;

Array: APAR ElsArray FPAR
    | APAR FPAR 
    | APAR NEWLINE ElsArray FPAR 
    | APAR NEWLINE ElsArray NEWLINE FPAR 
    | APAR ElsArray NEWLINE FPAR 
    ;

ElsArray: ElsArray VIRG Valor
    | ElsArray VIRG NEWLINE Valor
    | Valor
    ;

Aspas: ASPA string ASPA       {printf("Sou aspas\n");}
    ;

%%

int main(){
    ///for (int i = 0; i < MAXBLOCO; i++)
	//	  blocos[i] = NULL;
    
    yyparse();
    return 0;
}


int yyerror(char* s){
   printf("erro: %s\n",s);
}

