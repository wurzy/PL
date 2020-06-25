%{
int yylex();
int yyerror(char* s);
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
    | '[' NEWLINE ElsArray ']'
    | '[' NEWLINE ElsArray NEWLINE ']'
    | '[' ElsArray NEWLINE ']'
    ;

ElsArray: ElsArray ',' Valor
    | ElsArray ',' NEWLINE Valor
    | Valor
    ;

Aspas: '\"' '.' '\"'       {printf("Sou aspas\n");}
    ;

%%

int yylex(){
   return getchar();
}

int main(){
    yyparse();
    return 0;
}

int yyerror(char* s){
   printf("erro: %s\n",s);
}

