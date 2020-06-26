%{
int yylex();
int yyerror(char* s);
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

%}

%token TITLE valor chave string NEWLINE2
%union{ 
    char c;
	char* s;
}

%type <s> TITLE valor chave string NEWLINE2

%%

Toml: TITLE '=' Aspas NEWLINE2 Blocos '$'    {printf("0\n");}
    ;

Blocos: Blocos Bloco                       {printf("1.1\n");}
    |                                      {printf("1.2\n");}
    ;

Bloco: TagBloco '\n' ElsBloco NEWLINE2      {printf("aaaaaaaaaaaaaa\n");}
    ;

ElsBloco: ElsBloco '\n' ElemBloco           {printf("4.1\n");}
    | ElemBloco                             {printf("4.2\n");}
    ;

ElemBloco: ChaveValor                       {printf("5.1\n");}
    | Bloco                                 {printf("5.2\n");}
    ;   

TagBloco: '[' chave ']'                     {printf("3\n");}
    ;

ChaveValor: chave '=' Valor               {printf("6\n");}
    ;

Valor: Aspas                                {printf("7.1\n");}
    | valor                                 {printf("7.2\n");}
    | Array                                 {printf("7.3\n");}
    ;

Array: '[' ElsArray ']'                   {printf("8.1\n");} 
    | '[' ']'                             {printf("8.2\n");} 
    | '[' '\n' ElsArray ']'            {printf("8.3\n");} 
    | '[' '\n' ElsArray '\n' ']'    {printf("8.4\n");} 
    | '[' ElsArray '\n' ']'            {printf("8.5\n");} 
    ;

ElsArray: ElsArray ',' Valor               {printf("9.1\n");} 
    | ElsArray ',' '\n' Valor           {printf("9.2\n");} 
    | Valor                                 {printf("9.3\n");} 
    ;

Aspas: '\"' string '\"'                     {printf("10\n");}   
    ;

%%

int main(){
    ///for (int i = 0; i < MAXBLOCO; i++)
	//	  blocos[i] = NULL;
    
    yyparse();
    return 0;
}


int yyerror(char* s){
    extern int yylineno;
    extern char* yytext;
    fprintf(stderr, "Linha %d: %s (%s)\n",yylineno,s,yytext);
}

