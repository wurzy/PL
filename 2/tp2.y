%{
#define _GNU_SOURCE 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define MAXBLOCO 1024

extern FILE * yyin;
extern int bloco;
FILE* yyout;

int yylex();
int yyerror(char* s);
char* stringIndent();
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
                                                if(strlen($1) > 0) asprintf(&$$,"%s,\n  %s",$1,$2);
                                                else asprintf(&$$,"\n  %s",$2);
                                            }
    |                                       {$$ = "";}
    ;

Bloco: TagBloco FIMTAG ElsBloco FIMBLOCO    {
                                                char* indentacao = stringIndent();
                                                asprintf(&$$,"%s%s\n  %s}",$1,$3,indentacao);
                                            }
    ;

ElsBloco: ElsBloco ElemBloco                {asprintf(&$$,"%s,\n  %s",$1,$2);}
    | ElemBloco                             {asprintf(&$$,"  %s",$1);}
    ;

ElemBloco: ChaveValor                       {
                                                char* indentacao = stringIndent();
                                                asprintf(&$$,"%s%s",indentacao,$1);
                                            }
    | Bloco                                 {asprintf(&$$,"%s",$1);}
    ;   

TagBloco: '[' chave ']'                     {
                                                char* indentacao = stringIndent();
                                                asprintf(&$$,"%s\"%s\": {\n",indentacao,$2);
                                            }
    ;

ChavesValores: ChavesValores ChaveValor     {
                                                if(strlen($1) > 0) asprintf(&$$,"%s,\n%s",$1,$2);
                                                else asprintf(&$$,"\n%s",$2);
                                            }
    |                                       {$$ = "";}
    ;

ChaveValor: chave '=' Valor                 {asprintf(&$$,"  \"%s\": %s",$1,$3);}
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

char* stringIndent(){
    char* indentacao = malloc(strlen(""));
    indentacao[0] = '\0';
    for (int i = 0; i < bloco-1; i++)
       strcat(indentacao,"  ");
    return indentacao;
}
