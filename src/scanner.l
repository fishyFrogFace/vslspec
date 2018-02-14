%{
#include <vslc.h>
%}
%option noyywrap
%option array
%option yylineno

%%
FUNC                    { return FUNC; }
.                       { return yytext[0]; }
%%
