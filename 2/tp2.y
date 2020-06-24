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

Blocos: Bloco MaisBlocos
    ;

MaisBlocos: Bloco MaisBlocos
    | 
    ;

Bloco: TagBloco ElemBloco RestoBloco
    ;

TagBloco: '[' CHAVE ']'
    ;

RestoBloco: ElemBloco RestoBloco
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

Array: '[' ElsArray ']'
    ;

ElsArray: Valor OutrosElsArray
    | 
    ;

OutrosElsArray: ',' Valor OutrosElsArray 
    | 
    ;

Aspas: '"' STRING '"'
    ;

%%

int main(){
    yyparse();
    return 0;
}

void yyerror(char* s){
   printf("ERRO\n");
}
