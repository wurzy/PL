%{
#define _GNU_SOURCE 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MAXBLOCO 1024

int yylex();
int yyerror(char* s);
extern FILE * yyin;
FILE* yyout;

%}

%token TITLE valor chave string FIMTITULO FIMTAG FIMBLOCO
%union{ 
    char* s;
}

%type <s> TITLE valor chave string
%type <s> Blocos Bloco ElsBloco ElemBloco TagBloco ChaveValor Valor Array ElsArray Aspas

%%

Toml: TITLE '=' Aspas FIMTITULO Blocos      {fprintf(yyout,"{\n  \"title\": %s%s\n}",$3,$5);}
    ;

Blocos: Blocos Bloco                        {asprintf(&$$,"%s,\n  %s",$1,$2);}
    |                                       {$$ = "";}
    ;

Bloco: TagBloco FIMTAG ElsBloco FIMBLOCO    {asprintf(&$$,"%s%s\n  }",$1,$3);}
    ;

ElsBloco: ElsBloco ElemBloco                {asprintf(&$$,"%s,\n    %s",$1,$2);}
    | ElemBloco                             {asprintf(&$$,"  %s",$1);}
    ;

ElemBloco: ChaveValor                       {asprintf(&$$,"%s",$1);}
    | Bloco                                 {asprintf(&$$,"%s",$1);}
    ;   

TagBloco: '[' chave ']'                     {asprintf(&$$,"\"%s\": {\n  ",$2);}
    ;

ChaveValor: chave '=' Valor                 {asprintf(&$$,"\"%s\": %s",$1,$3);}
    ;

Valor: Aspas                                {asprintf(&$$,"%s",$1);}
    | valor                                 {asprintf(&$$,"%s",$1);}
    | Array                                 {asprintf(&$$,"%s",$1);}
    ;

Array: '[' ElsArray ']'                     {asprintf(&$$,"[\n%s\n    ]",$2);} 
    | '[' ']'                               {asprintf(&$$,"[],\n");}
    ;

ElsArray: ElsArray ',' Valor                {asprintf(&$$,"%s,\n      %s",$1,$3);}
    | Valor                                 {asprintf(&$$,"      %s",$1);} 
    ;

Aspas: '"' string '"'                     {asprintf(&$$,"\"%s\"",$2);}   
    ;

%%

int main(int argc, char* argv[]){
    yyin = fopen(argv[1],"r");

    if (argv[2]) yyout = fopen(argv[2],"w");
    else yyout = fopen(strcat(argv[1],".json"),"w");

    extern char *blocos[MAXBLOCO];
    for (int i = 0; i < MAXBLOCO; i++)
        blocos[i] = NULL;
    
    yyparse();
    fclose(yyin);
    fclose(yyout);
    return 0;
}


int yyerror(char* s){
    extern int yylineno;
    extern char* yytext;
    fprintf(stderr, "Linha %d: %s (%s)\n",yylineno,s,yytext);
}
