%{
 int yylex();
 void yyerror(char*);
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

%}

%token TITLE VALOR CHAVE STRING 

%%

Toml: TITLE '=' Aspas Blocos
    ;

Blocos: Bloco Blocos
    | 
    ;

Bloco: ElemBloco 
    | 
    ;

ElemBloco: ChaveValor 
    | Bloco 
    ;

ChaveValor: CHAVE '=' Valor 
    ;

Valor: Aspas
    | VALOR 
    | Array 
    ;

Array: '[' Elems ']'
    ;

Elems: Valor OutrosElems 
    | 
    ;

OutrosElems: ',' Valor OutrosElems
    |
    ;

Aspas: '"' STRING '"' 
%%

int main(){
    yyparse();
    return 0;
}

void yyerror(char* s){
   printf("ERRO\n");
}
