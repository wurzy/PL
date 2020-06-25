%option noyywrap yylineno
%x BLOCO SUBBLOCO NOMEBLOCO VALORBLOCO VALOR ARRAY ESPACOS VALORTITULO INITBLOCO INITCHAVE ASPASBLOCO ASPASARRAY
%{
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include "y.tab.h"

#define MAXBLOCO 1024

int newlines = 0;
int bloco = 0;
int aspa = 0;
//char *blocos[MAXBLOCO];

%}

digito    [0-9]
acentos   \xc3[\x80-\xbf]         
letra     [a-zA-Z]|{acentos}       
palavra   {letra}+  
espacos   [ ]*  

%%

<*>title{espacos}                               {BEGIN VALORTITULO; return TITLE;}
<*>/\[                                 {
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
                                                //blocos[bloco] = strdup(yytext);
                                                bloco++;
                                                return chave;  
                                                }
<NOMEBLOCO>\]                                   {return FPAR;}
<NOMEBLOCO>\n                                   {BEGIN BLOCO; return NEWLINE;}                                                                          

<BLOCO>/[a-z][^ \n\t]*                 {newlines = 0; BEGIN INITCHAVE; return NEWLINE;}
<BLOCO>\n                                       {newlines++;}

<INITCHAVE>[a-z][^ \n\t]*                       {BEGIN VALORBLOCO; return chave;}

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
<VALORBLOCO>{espacos}\"                         {BEGIN ASPASBLOCO; return ASPA;}
<VALORBLOCO>{espacos}\[                         {BEGIN ESPACOS; return APAR;}
<VALORBLOCO>{espacos}                           {BEGIN VALOR;}

<VALOR>[^ \t\n\r#]+                             {BEGIN BLOCO; return valor;} 

<ASPASBLOCO>\"                                  {BEGIN BLOCO; return ASPA;}
<ASPASBLOCO>[^"]*                               {return string; }

<ARRAY>{espacos},                               {BEGIN ESPACOS; return VIRG;}
<ARRAY>[^,\] \n\t\r]+                           {return valor;}
<ARRAY>\]                                       {BEGIN BLOCO; return FPAR;}
<ARRAY>{espacos}\n                              {return NEWLINE;}

<ASPASARRAY>\"                                  {BEGIN ARRAY; return ASPA;}
<ASPASARRAY>[^"]*                               {return string; }

<ESPACOS>{espacos}                              {BEGIN ARRAY;}
<ESPACOS>{espacos}\"                            {BEGIN ASPASARRAY; return ASPA;}
<ESPACOS>{espacos}\n                            {return NEWLINE;}

<*>.                                            {}

%% 

