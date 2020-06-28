%option noyywrap yylineno
%x BLOCO NOMEBLOCO VALORBLOCO VALOR ARRAY VALORTITULO ASPASBLOCO ASPASARRAY
%{
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include "y.tab.h"

#define MAXBLOCO 1024

int tokens[3] = {0}; //FIMBLOCO, '[', chave
int aspaTitulo = 0;
char *blocos[MAXBLOCO];

int primeiroBloco = 0;
int blocoAtual = 0;
int blocoDpsTokens = 0;

int arrayAtual = 0;
int decArrayAtual = 0;

int tokensAcumulados();
void atualizaBlocos();

%}

digito    [0-9]
acentos   \xc3[\x80-\xbf]         
letra     [a-zA-Z]|{acentos}       
palavra   {letra}+  
espacos   [ ]*  

%%
  if (decArrayAtual == 1) {arrayAtual--; decArrayAtual = 0;}
  if (blocoAtual > blocoDpsTokens) blocoAtual--;
  if (blocoAtual < blocoDpsTokens) blocoAtual++;

  int token = tokensAcumulados();
  switch(token){
    case 0: return FIMBLOCO;
    case 1: return '[';
    case 2: yylval.s = strdup(blocos[blocoAtual-1]); return chave;
  }

<*>#.*                                          {}

<NOMEBLOCO>\[                                   {tokens[1] = 1;}
<NOMEBLOCO>[^\]\[\n]+                           {
                                                  atualizaBlocos(yytext);
                                                  int token = tokensAcumulados();
                                                  if (token == 0) return FIMBLOCO;
                                                  if (token == 1) return '[';
                                                }
<NOMEBLOCO>\]                                   {return ']';}
<NOMEBLOCO>{espacos}\n{espacos}/\[?             {BEGIN BLOCO; return FIMTAG;}                                                                        

<BLOCO>[a-z][^ \n\t\r]*                         {BEGIN VALORBLOCO; yylval.s = strdup(yytext); return chave;}
<BLOCO>\[                                       {tokens[1] = 1; BEGIN NOMEBLOCO;}

<VALORTITULO>={espacos}                         {return '=';}
<VALORTITULO>\"                                 {return '"';}
<VALORTITULO>[^"=\n]+                           {yylval.s = strdup(yytext); return string;}
<VALORTITULO>{espacos}\n{espacos}/\[            {BEGIN NOMEBLOCO; return FIMTITULO;}
<VALORTITULO>{espacos}\n                        {BEGIN 0; return FIMTITULO;}

<VALORBLOCO>{espacos}=                          {return '=';}
<VALORBLOCO>{espacos}\"                         {BEGIN ASPASBLOCO; return '"';}
<VALORBLOCO>{espacos}\[                         {BEGIN ARRAY; arrayAtual++; return '[';}
<VALORBLOCO>{espacos}                           {BEGIN VALOR;}

<VALOR>[0-2][0-9]:[0-5][0-9]:[0-5][0-9]                             {
                                                                      char horas[100]; 
                                                                      sprintf(horas,"\"%s\"",yytext); 
                                                                      yylval.s = strdup(horas);
                                                                      BEGIN BLOCO;
                                                                      return valor;
                                                                    }
<VALOR>[0-9]{4}-(0[1-9]|1[0-2])-([1-2][0-9]|0[1-9]|3[01])           {
                                                                      char data[100]; 
                                                                      sprintf(data,"\"%s\"",yytext); 
                                                                      yylval.s = strdup(data); 
                                                                      BEGIN BLOCO;
                                                                      return valor;
                                                                    }
<VALOR>[^ \t\n\r#]+                                                 {BEGIN BLOCO; yylval.s = strdup(yytext); return valor;} 

<ASPASBLOCO>\"                                  {BEGIN BLOCO; return '"';}
<ASPASBLOCO>[^"]+                               {yylval.s = strdup(yytext); return string; }

<ARRAY>,                                        {return ',';}
<ARRAY>\"                                       {BEGIN ASPASARRAY; return '"';}
<ARRAY>[^,\[\] \n\t\r]+                         {yylval.s = strdup(yytext); return valor;}
<ARRAY>\[                                       {arrayAtual++; return '[';}
<ARRAY>\]                                       {
                                                  decArrayAtual = 1; 
                                                  if(arrayAtual-1 == 0) BEGIN BLOCO;
                                                  return ']';
                                                }

<ASPASARRAY>\"                                  {BEGIN ARRAY; return '"';}
<ASPASARRAY>[^"]+                               {yylval.s = strdup(yytext); return string; }

<*><<EOF>>                                      {
                                                  if (blocoDpsTokens > 0) {
                                                    tokens[0] = blocoDpsTokens-1;
                                                    blocoDpsTokens = 0;
                                                    return FIMBLOCO;
                                                  }
                                                  else if (primeiroBloco == 0) {
                                                    primeiroBloco = 1;
                                                    return INITBLOCOS;
                                                  }
                                                  else yyterminate();
                                                }

<*>{espacos}\n{espacos}/\[                      {
                                                  BEGIN NOMEBLOCO;
                                                  if (primeiroBloco == 0) {
                                                    primeiroBloco = 1;
                                                    return INITBLOCOS;
                                                  }
                                                }

<*>[a-z][^ \n\t\r\]\"]*                         {BEGIN VALORBLOCO; yylval.s = strdup(yytext); return chave;}
<*>{espacos}\n                                  {}
<*>.                                            {}

%%

int tokensAcumulados() {
  if (tokens[0] > 0) {
    if (tokens[0] == 1) {tokens[0] = -1;}
    else {tokens[0]--;}
    return 0;
  }
  if (tokens[0] == -1 && tokens[1] > 0) {
    tokens[1] = 0;
    return 1;
  }
  if (tokens[0] == -1 && tokens[2] > 0) {
    tokens[0] = 0;
    tokens[2] = 0;
    return 2;
  }
  return -1;
}

void atualizaBlocos(char* yytext) {
  int subbloco = 0;
  int blocoInit = blocoAtual;

  if (blocoAtual > 0) {
    char blocoAcima[1024];
    for (int i = blocoAtual-1; i >= 0; i--) {
      sprintf(blocoAcima,"%s.",blocos[i]);
      char* pos = strstr(yytext, blocoAcima);

      if(pos != NULL) { //subbloco
        if (i == blocoAtual-1) { //subbloco num novo nivel: servers -> servers.alpha
          blocos[blocoAtual] = strdup(pos+strlen(blocoAcima));
          blocoDpsTokens = blocoAtual+1;
        }
        else { //subbloco no nivel atual: servers.alpha -> servers.beta
          for (int j = i+1; j < blocoAtual; j++){
            free(blocos[j]);
            blocos[j] = NULL;
          }
          blocos[i+1] = strdup(pos+strlen(blocoAcima));
          blocoDpsTokens = i+2;
        }
        subbloco = 1;
        break;
      }
    }
  }

  if (subbloco == 0) {
    for (int i = 0; i < blocoAtual; i++){
      free(blocos[i]);
      blocos[i] = NULL;
    }
    blocos[0] = strdup(yytext);
    blocoDpsTokens = 1;
  }

  if (blocoInit >= blocoDpsTokens) tokens[0] = blocoInit-blocoDpsTokens+1;
  else tokens[0] = -1;
  tokens[2] = 1;
}
