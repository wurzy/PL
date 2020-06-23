%option noyywrap yylineno
%x BLOCO SUBBLOCO ASPAS NOMEBLOCO VALOR ARRAY ESPACOS
%{
#include <stdio.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>

#define MAXBLOCO 1024

int bloco = 0;
char *blocos[MAXBLOCO];

%}

digito    [0-9]
acentos   \xc3[\x80-\xbf]           
letra     [a-zA-Z]|{acentos}       
palavra   {letra}+  
espacos   [ ]*  

%%

<*>title{espacos}=                              {printf("TITLE:%s\n",yytext);BEGIN VALOR;}
<*>^{espacos}\[                                           {BEGIN NOMEBLOCO;}
<*>#.*\n                                        {printf("COMMENT:%s",yytext);}

<NOMEBLOCO>[^]]*\]                              {
                                                yytext[yyleng-1] = '\0';
                                                printf("NOMEBLOCO:%s\n",yytext);
                                                blocos[bloco] = strdup(yytext);
                                                bloco++;
                                                BEGIN BLOCO;   
                                                }                                 

<BLOCO>[^ \n]*{espacos}=                        {
                                                yytext[yyleng-1] = '\0';
                                                printf("KEY:%s\n",yytext);
                                                BEGIN VALOR;}
<BLOCO>\n\n                                     {
                                                free(blocos[bloco]);
                                                bloco--; 
                                                if(bloco==0) BEGIN 0;
                                                }

<VALOR>{espacos}\[                              {BEGIN ESPACOS;}
<VALOR>[^[\n]*\n                                {printf("VALOR:%s\n",yytext); BEGIN BLOCO;}


<ARRAY>,                                        {BEGIN ESPACOS;}
<ARRAY>[^,\]\n]*                                {printf("Elem:%s",yytext);}
<ARRAY>\]                                       {printf("\n");BEGIN BLOCO;}

<ESPACOS>{espacos}                              {BEGIN ARRAY;}


<*>\n                                           {}

%% 

int main(){
    for (int i = 0; i < MAXBLOCO; i++)
		blocos[i] = NULL;
    
    yylex();
    return 0;
}
