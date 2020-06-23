%{
 int yylex();
 void yyerror(char*);
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

double mem[128];
double ans;

%}

%%



%%

int main(){
    yyparse();
    return 0;
}

void yyerror(char* s){
   printf("ERRO\n");
}
