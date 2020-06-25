%{
int yylex();
void yyerror(char*);
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

%}

%token TITLE VALOR CHAVE STRING NEWLINE NEWLINE2

%%

Toml: TITLE '=' Aspas NEWLINE2 Blocos
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

TagBloco: '[' CHAVE ']'
    ;

ChaveValor: CHAVE '=' Valor

Valor: Aspas 
    | VALOR 
    | Array
    ;

Array: '[' ElsArray ']'
    | '[' ']'
    ;

ElsArray: ElsArray ',' Valor
    | Valor
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
