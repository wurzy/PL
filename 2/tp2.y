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

Blocos: Blocos Bloco
    | 
    ;

Bloco: TagBloco ElsBloco
    ;

TagBloco: '[' CHAVE ']'
    ;

ElsBloco: ElsBloco ElemBloco
    | ElemBloco
    ;

ElemBloco: CHAVE '=' Valor 
    | Bloco 
    ;

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
