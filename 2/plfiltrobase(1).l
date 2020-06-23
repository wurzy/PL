%{
//#include "y.tab.h"
void yyerror(char* s);
%}
%option noyywrap  yylineno

/* Abreviaturas de ER */
digito    [0-9]
acentos   \xc3[\x80-\xbf]           
letra     [a-zA-Z]|{acentos}       
palavra   {letra}+         

%%
[ \n]       {}
#.*         {}
[,]         { }
(?i:inicio) { }
(?i:fim)    {}
[a-zA-Z]+   {}
[0-9]+      {}
.           { yyerror("Simbolo desconhecido");}

%%