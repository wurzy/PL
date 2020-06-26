%option noyywrap yylineno
%x BLOCO SUBBLOCO NOMEBLOCO VALORBLOCO VALOR ARRAY ESPACOS VALORTITULO ASPASBLOCO ASPASARRAY
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
<*>#.*                                          {}

<NOMEBLOCO>\[                                   {return '[';}
<NOMEBLOCO>[^\]\[\n]+                           {
                                                //blocos[bloco] = strdup(yytext);
                                                bloco++;
                                                return chave;  
                                                }
<NOMEBLOCO>\]                                   {return ']';}
<NOMEBLOCO>{espacos}\n/\[?                      {BEGIN BLOCO; return '\n';}                                                                        

<BLOCO>{espacos}[a-z][^ \n\t\r]*                  {newlines = 0; BEGIN VALORBLOCO; return chave;}
<BLOCO>{espacos}\n{espacos}/(\n|#)              {
                                                  BEGIN 0;
                                                  bloco--;
                                                  printf("bloco acabado\n");
                                                  if(bloco > 0){
                                                    return '\n';
                                                  }
                                                  else {
                                                    newlines++;
                                                  } 
                                                }  
<BLOCO>{espacos}\n                              {return '\n';}
<BLOCO>\[                                       {BEGIN NOMEBLOCO; return '[';}

<VALORTITULO>{espacos}=                         {return '=';}
<VALORTITULO>{espacos}\"                        {
                                                  if(aspa==0){
                                                    aspa++;
                                                  }
                                                  else {
                                                    aspa--;
                                                    BEGIN 0;
                                                  } 
                                                  return '\"';
                                                }
<VALORTITULO>[^"=\n]*                           {return string;}

<VALORBLOCO>{espacos}=                          {return '=';}
<VALORBLOCO>{espacos}\"                         {BEGIN ASPASBLOCO; return '\"';}
<VALORBLOCO>{espacos}\[                         {BEGIN ESPACOS; return '[';}
<VALORBLOCO>{espacos}                           {BEGIN VALOR;}

<VALOR>[^ \t\n\r#]+                             {BEGIN BLOCO; return valor;} 

<ASPASBLOCO>\"                                  {BEGIN BLOCO; return '\"';}
<ASPASBLOCO>[^"]*                               {return string; }

<ARRAY>{espacos},                               {BEGIN ESPACOS; return ',';}
<ARRAY>[^,\] \n\t\r]+                           {return valor;}
<ARRAY>\]                                       {BEGIN BLOCO; return ']';}
<ARRAY>{espacos}\n                              {return '\n';}

<ASPASARRAY>\"                                  {BEGIN ARRAY; return '\"';}
<ASPASARRAY>[^"]*                               {return string; }

<ESPACOS>{espacos}                              {BEGIN ARRAY;}
<ESPACOS>{espacos}\"                            {BEGIN ASPASARRAY; return '\"';}
<ESPACOS>{espacos}\n                            {return '\n';}

<*>\n/\[                                        {
                                                  BEGIN NOMEBLOCO;
                                                  if(bloco == 0){
                                                    newlines++;
                                                  }
                                                  if(newlines >= 2){
                                                    newlines = 0;
                                                    return NEWLINE2;
                                                  }
                                                }
<*>\n                                           {
                                                  if(bloco == 0){
                                                    newlines++;
                                                  }
                                                }

<BLOCO>{espacos}[a-z][^ \n\t\r\]]*              {BEGIN VALORBLOCO; return chave;}
<<EOF>>                                         {printf("ola\n"); return '$';}                                        
<*>.                                            {}

%% 

