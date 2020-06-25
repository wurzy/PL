%option noyywrap yylineno
%x BLOCO SUBBLOCO ASPAS NOMEBLOCO VALORBLOCO ARRAY ESPACOS VALORTITULO INITBLOCO
%{
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

#define MAXBLOCO 1024

int c_atual = 0;
int newlines = 0;
int bloco = 0;
int aspa = 0;
char *blocos[MAXBLOCO];

%}

digito    [0-9]
acentos   \xc3[\x80-\xbf]           
letra     [a-zA-Z]|{acentos}       
palavra   {letra}+  
espacos   [ ]*  

%%

<*>title{espacos}                               {BEGIN VALORTITULO; return TITLE;}
<*>^/\[                                         {
                                                  if(newlines>=2){
                                                    newlines = 0;
                                                    return NEWLINE2;
                                                  }
                                                  BEGIN INITBLOCO;
                                                }
<*>#.*                                          {}
<*>\n                                           {newlines++;}

<INITBLOCO>\[                                   {BEGIN NOMEBLOCO; return APAR;}

<NOMEBLOCO>[^\]]+                               {
                                                blocos[bloco] = strdup(yytext);
                                                bloco++;
                                                return chave;  
                                                }
<NOMEBLOCO>\]                                   {return FPAR;}
<NOMEBLOCO>\n                                   {BEGIN BLOCO; return NEWLINE;}                                                                          

<BLOCO>[a-z][^ \n\t]*                           {BEGIN VALORBLOCO; return chave;}
<BLOCO>\n\n                                     {BEGIN 0; return NEWLINE2;}
<BLOCO>\n                                       {return NEWLINE;}

<VALORTITULO>{espacos}=                         {return IGUAL;}
<VALORTITULO>{espacos}\"                        {
                                                  if(aspa==0){
                                                    aspa++;
                                                  }
                                                  else {
                                                    aspa--;
                                                    BEGIN 0;
                                                  } 
                                                  return ASPA;
                                                }
<VALORTITULO>[^"]*                              {return string;}

<VALORBLOCO>{espacos}=                          {return IGUAL;}
<VALORBLOCO>{espacos}\"                         {BEGIN ASPAS; return ASPA;}
<VALORBLOCO>{espacos}\[                         {BEGIN ESPACOS; return APAR;}
<VALORBLOCO>{espacos}                           {BEGIN VALOR;}

<VALOR>[^ \t\n#]+                               {BEGIN BLOCO; return valor;} 

<ASPAS>\"                                       {BEGIN BLOCO; return ASPA;}
<ASPAS>[^"]*                                    {return string; }

<ARRAY>,                                        {BEGIN ESPACOS; return VIRG;}
<ARRAY>[^,\]\n]+                                {return valor;}
<ARRAY>\]                                       {BEGIN BLOCO; return FPAR;}

<ESPACOS>{espacos}/\"                           {}
<ESPACOS>{espacos}/\[                           {}
<ESPACOS>{espacos}                              {}


<*>.                                            {}

%% 

int main(){
    for (int i = 0; i < MAXBLOCO; i++)
		  blocos[i] = NULL;
    
    yylex();
    return 0;
}
