%{
#include <vslc.h>
%}
%option noyywrap
%option array
%option yylineno

DIGIT                   [0-9]
NUMBER                  {DIGIT}+
LETTER                  [a-zA-Z_]
STRING                  \"([^\n])*\"
IDENTIFIER              {LETTER}({LETTER}|{DIGIT})*
COMMENT                 \/\/.*\n
WSCHARS                 [\t\n\r\v ]
WHITESPACE              {WSCHARS}+

%%
FUNC                    { return FUNC; }
BEGIN                   { return OPENBLOCK; }
END                     { return CLOSEBLOCK; }
RETURN                  { return RETURN; }
PRINT                   { return PRINT; }
CONTINUE                { return CONTINUE; }
IF                      { return IF; }
THEN                    { return THEN; }
ELSE                    { return ELSE; }
WHILE                   { return WHILE; }
DO                      { return DO; }
VAR                     { return VAR; }
(:=)                    { return ASSIGN; }
(>>)                    { return RSHIFT; }
(<<)                    { return LSHIFT; }
{NUMBER}                { return NUMBER; }
{STRING}                { return STRING; }
{IDENTIFIER}            { return IDENTIFIER; }
{WHITESPACE}            /* do nothing */
{COMMENT}               /* do nothing */
.                       { return yytext[0]; }
%%
