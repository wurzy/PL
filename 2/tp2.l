%option noyywrap yylineno
%x BLOCO NOMEBLOCO VALORBLOCO VALOR ARRAY ESPACOS VALORTITULO ASPASBLOCO ASPASARRAY
%{
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include "y.tab.h"

#define MAXBLOCO 1024

int tokens[3] = {0}; //FIMBLOCO, '[', chave
int bloco = 0;
int aspaTitulo = 0;
char *blocos[MAXBLOCO];

int tokensAcumulados();
void atualizaBlocos();

%}

digito    [0-9]
acentos   \xc3[\x80-\xbf]         
letra     [a-zA-Z]|{acentos}       
palavra   {letra}+  
espacos   [ ]*  

%%
  int token = tokensAcumulados();
  switch(token){
    case 0: return FIMBLOCO;
    case 1: return '[';
    case 2: {yylval.s = strdup(blocos[bloco-1]); return chave;}
  }

<*>title{espacos}                               {BEGIN VALORTITULO; return TITLE;}
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
<VALORBLOCO>{espacos}\[                         {BEGIN ESPACOS; return '[';}
<VALORBLOCO>{espacos}                           {BEGIN VALOR;}

<VALOR>[^ \t\n\r#]+                             {BEGIN BLOCO; yylval.s = strdup(yytext); return valor;} 

<ASPASBLOCO>\"                                  {BEGIN BLOCO; return '"';}
<ASPASBLOCO>[^"]+                               {yylval.s = strdup(yytext); return string; }

<ARRAY>{espacos},                               {BEGIN ESPACOS; return ',';}
<ARRAY>[^,\] \n\t\r]+                           {yylval.s = strdup(yytext); return valor;}
<ARRAY>\]                                       {BEGIN BLOCO; return ']';}

<ASPASARRAY>\"                                  {BEGIN ARRAY; return '"';}
<ASPASARRAY>[^"]+                               {yylval.s = strdup(yytext); return string; }

<ESPACOS>{espacos}                              {BEGIN ARRAY;}
<ESPACOS>{espacos}\"                            {BEGIN ASPASARRAY; return '"';}

<*><<EOF>>                                      {
                                                  if (bloco > 1) {
                                                    tokens[0] = bloco-1;
                                                    bloco = 0;
                                                    return FIMBLOCO;
                                                  }
                                                  else yyterminate();
                                                }

<*>{espacos}\n{espacos}/\[                      {BEGIN NOMEBLOCO;}
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
  int blocoInit = bloco;

  if (bloco > 0) {
    char blocoAcima[1024];
    for (int i = bloco-1; i >= 0; i--) {
      sprintf(blocoAcima,"%s.",blocos[i]);
      char* pos = strstr(yytext, blocoAcima);

      if(pos != NULL) { //subbloco
        if (i == bloco-1) { //subbloco num novo nivel: servers -> servers.alpha
          blocos[bloco] = strdup(pos+strlen(blocoAcima));
          bloco++;
        }
        else { //subbloco no nivel atual: servers.alpha -> servers.beta
          for (int j = i+1; j < bloco; j++){
            free(blocos[j]);
            blocos[j] = NULL;
          }
          blocos[i+1] = strdup(pos+strlen(blocoAcima));
          bloco = i+2;
        }
        subbloco = 1;
        break;
      }
    }
  }

  if (subbloco == 0) {
    for (int i = 0; i < bloco; i++){
      free(blocos[i]);
      blocos[i] = NULL;
    }
    blocos[0] = strdup(yytext);
    bloco = 1;
  }

  if (blocoInit >= bloco) tokens[0] = blocoInit-bloco+1;
  else tokens[0] = -1;
  tokens[2] = 1;
}
