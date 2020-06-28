%{
#define _GNU_SOURCE 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MAXBLOCO 1024

extern FILE * yyin;
extern int primeiroBloco;
extern int blocoAtual;
extern int arrayAtual;
FILE* yyout;

int yylex();
int yyerror(char* s);
char* indent(int iter);
%}

%token TITLE valor chave string INITBLOCOS FIMTITULO FIMTAG FIMBLOCO
%union{ 
    char* s;
}

%type <s> valor chave string
%type <s> Blocos Bloco ElsBloco ElemBloco TagBloco ChavesValores ChaveValor Valor Array ElsArray Aspas

%%

Toml: ChavesValores INITBLOCOS Blocos       {
                                                if(strlen($3) == 0) fprintf(yyout,"{%s\n}",$1);
                                                else if(strlen($1) == 0) fprintf(yyout,"{%s\n}",$3);
                                                else fprintf(yyout,"{%s,%s\n}",$1,$3);
                                            }
    ;

Blocos: Blocos Bloco                        {
                                                if(strlen($1) > 0) asprintf(&$$,"%s,\n%s",$1,$2);
                                                else asprintf(&$$,"\n%s",$2);
                                            }
    |                                       {$$ = "";}
    ;

Bloco: TagBloco FIMTAG ElsBloco FIMBLOCO    {
                                                char* indentacao = indent(blocoAtual);
                                                asprintf(&$$,"%s%s\n%s}",$1,$3,indentacao);
                                            }
    ;

ElsBloco: ElsBloco ElemBloco                {asprintf(&$$,"%s,\n%s",$1,$2);}
    | ElemBloco                             {asprintf(&$$,"%s",$1);}
    ;

ElemBloco: ChaveValor                       {
                                                char* indentacao = indent(blocoAtual);
                                                asprintf(&$$,"%s%s",indentacao,$1);
                                            }
    | Bloco                                 {asprintf(&$$,"%s",$1);}
    ;   

TagBloco: '[' chave ']'                     { 
                                                char* indentacao = indent(blocoAtual);
                                                asprintf(&$$,"%s\"%s\": {\n",indentacao,$2);
                                            }
    ;

ChavesValores: ChavesValores ChaveValor     {
                                                if(strlen($1) > 0) asprintf(&$$,"%s,\n%s",$1,$2);
                                                else asprintf(&$$,"\n%s",$2);
                                            }
    |                                       {$$ = "";}
    ;

ChaveValor: chave '=' Valor                 {
                                                char* indentacao = indent(blocoAtual);
                                                asprintf(&$$,"%s\"%s\": %s",indentacao,$1,$3);
                                            }
    ;                                       

Valor: Aspas                                {asprintf(&$$,"%s",$1);}
    | valor                                 {asprintf(&$$,"%s",$1);}
    | Array                                 {asprintf(&$$,"%s",$1);}
    ;

Array: '[' ElsArray ']'                     {
                                                char* indentacao = indent(blocoAtual+arrayAtual);
                                                asprintf(&$$,"[\n%s\n%s]",$2,indentacao);
                                            } 
    | '[' ']'                               {asprintf(&$$,"[]");}
    ;

ElsArray: ElsArray ',' Valor                {
                                                char* indentacao;
                                                if ($3[0] == '[') indentacao = indent(blocoAtual+arrayAtual);
                                                else indentacao = indent(blocoAtual+arrayAtual+1);
                                                asprintf(&$$,"%s,\n%s%s",$1,indentacao,$3);
                                            }
    | Valor                                 {
                                                char* indentacao;
                                                if ($1[0] == '[') indentacao = indent(blocoAtual+arrayAtual);
                                                else indentacao = indent(blocoAtual+arrayAtual+1);
                                                asprintf(&$$,"%s%s",indentacao,$1);
                                            } 
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

char* indent(int iter){
    char* indentacao = malloc(strlen(""));
    indentacao[0] = '\0';

    if(primeiroBloco==0) iter++;    
    for (int i = 0; i < iter; i++)
       strcat(indentacao,"  ");
    return indentacao;
}
