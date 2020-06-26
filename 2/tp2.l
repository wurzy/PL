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

<NOMEBLOCO>\[                                   {newlines = 0; return '[';}
<NOMEBLOCO>[^\]\[\n]+                           {printf("ola %s\n", yytext);
                                                  //blocos[bloco] = strdup(yytext);
                                                  bloco++;
                                                  yylval.s = strdup(yytext);
                                                  return chave;  
                                                }
<NOMEBLOCO>\]                                   {return ']';}
<NOMEBLOCO>{espacos}\n/\[?                      {BEGIN BLOCO; return '\n';}                                                                        

<BLOCO>{espacos}[a-z][^ \n\t\r]*                {newlines = 0; BEGIN VALORBLOCO; yylval.s = strdup(yytext); return chave;}
<BLOCO>{espacos}\n{espacos}/(\n|#)              {
                                                  BEGIN 0;
                                                  bloco--;
                                                  newlines++;
                                                }  
<BLOCO>{espacos}\n                              {}
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
<VALORTITULO>[^"=\n]*                           {yylval.s = strdup(yytext); return string;}

<VALORBLOCO>{espacos}=                          {return '=';}
<VALORBLOCO>{espacos}\"                         {BEGIN ASPASBLOCO; return '\"';}
<VALORBLOCO>{espacos}\[                         {BEGIN ESPACOS; return '[';}
<VALORBLOCO>{espacos}                           {BEGIN VALOR;}

<VALOR>[^ \t\n\r#]+                             {BEGIN BLOCO; yylval.s = strdup(yytext); return valor;} 

<ASPASBLOCO>\"                                  {BEGIN BLOCO; return '\"';}
<ASPASBLOCO>[^"]*                               {yylval.s = strdup(yytext); return string; }

<ARRAY>{espacos},                               {BEGIN ESPACOS; return ',';}
<ARRAY>[^,\] \n\t\r]+                           {yylval.s = strdup(yytext); return valor;}
<ARRAY>\]                                       {BEGIN BLOCO; return ']';}
<ARRAY>{espacos}\n                              {return '\n';}

<ASPASARRAY>\"                                  {BEGIN ARRAY; return '\"';}
<ASPASARRAY>[^"]*                               {yylval.s = strdup(yytext); return string; }

<ESPACOS>{espacos}                              {BEGIN ARRAY;}
<ESPACOS>{espacos}\"                            {BEGIN ASPASARRAY; return '\"';}
<ESPACOS>{espacos}\n                            {return '\n';}

<*>\n/\[                                        {
                                                  BEGIN NOMEBLOCO;
                                                  if(newlines!=-1){
                                                    newlines++; 
                                                  }
                                                  if(newlines >= 2){
                                                    newlines = -1;
                                                    return NEWLINE2;
                                                  }
                                                }
                                              
<*>\n                                           { 
                                                  if(newlines!=-1){
                                                    newlines++; 
                                                  }
                                                  if(newlines >= 2){
                                                    newlines = -1;
                                                    return NEWLINE2;
                                                  }
                                                }
<*><<EOF>>                                      {return NEWLINE2;}
<*>.                                            {}

%% 

