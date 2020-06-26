%{
int yylex();
int yyerror(char* s);

#define _GNU_SOURCE 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

%}

%token TITLE valor chave string NEWLINE2 FIM
%union{ 
	char* s;
}

%type <s> TITLE valor chave string NEWLINE2 FIM
%type <s> Toml Blocos Bloco ElsBloco ElemBloco TagBloco ChaveValor Valor Array ElsArray Aspas

%%

Toml: TITLE '=' Aspas NEWLINE2 Blocos       {printf("{\n  \"title\": %s,\n%s}",$3,$5);}
    ;

Blocos: Blocos Bloco                        {asprintf(&$$,"%s  %s",$1,$2);}
    |                                       {$$ = "";}
    ;

Bloco: TagBloco '\n' ElsBloco NEWLINE2      {asprintf(&$$,"%s%s  },\n",$1,$3);}
    ;

ElsBloco: ElsBloco ElemBloco                {asprintf(&$$,"%s    %s",$1,$2);}
    | ElemBloco                             {asprintf(&$$,"    %s",$1);}
    ;

ElemBloco: ChaveValor                       {asprintf(&$$,"%s",$1);}
    | Bloco                                 {asprintf(&$$,"%s",$1);}
    ;   

TagBloco: '[' chave ']'                     {asprintf(&$$,"\"%s\": {\n",$2);}
    ;

ChaveValor: chave '=' Valor                 {asprintf(&$$,"\"%s\": %s,\n",$1,$3);}
    ;

Valor: Aspas                                {asprintf(&$$,"%s",$1);}
    | valor                                 {asprintf(&$$,"%s",$1);}
    | Array                                 {asprintf(&$$,"%s",$1);}
    ;

Array: '[' ElsArray ']'                     {asprintf(&$$,"[\n%s\n    ]",$2);} 
    | '[' ']'                               {asprintf(&$$,"[],\n");} 
    | '[' '\n' ElsArray ']'                 {asprintf(&$$,"[\n%s\n    ]",$3);} 
    | '[' '\n' ElsArray '\n' ']'            {asprintf(&$$,"[\n%s\n    ]",$3);} 
    | '[' ElsArray '\n' ']'                 {asprintf(&$$,"[\n%s\n    ]",$2);} 
    ;

ElsArray: ElsArray ',' Valor                {asprintf(&$$,"%s,\n      %s",$1,$3);} 
    | ElsArray ',' '\n' Valor               {asprintf(&$$,"%s,\n      %s",$1,$4);} 
    | Valor                                 {asprintf(&$$,"      %s",$1);} 
    ;

Aspas: '\"' string '\"'                   {asprintf(&$$,"\"%s\"",$2);}   
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

