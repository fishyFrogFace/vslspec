%{
#include <vslc.h>
%}
%left '|'
%left '^'
%left '&'
%left LSHIFT RSHIFT
%left '+' '-'
%left '*' '/'
%nonassoc UMINUS
%right '~'
	//%expect 1

%token FUNC PRINT RETURN CONTINUE IF THEN ELSE WHILE DO OPENBLOCK CLOSEBLOCK
%token VAR NUMBER IDENTIFIER STRING LSHIFT RSHIFT ASSIGN

%%
program :
    global_list { /* no need for FUNC here? wat */
        root = (node_t *) malloc ( sizeof(node_t) );
        node_init ( root, PROGRAM, NULL, 0 );
    }
    ;

global_list:
    global
    | global_list global
    ;

global:
    function
    | declaration
    ;

statement_list:
    statement
    | statement_list statement
    ;

print_list:
    print_item
    | print_list ',' print_item
    ;

expr_list:
    expr
    | expr_list ',' expr
    ;

variable_list:
    identifier
    | variable_list ',' identifier
    ;

argument_list:
    expr_list
    | /* empty */ /* implicit empty rule = sadness, https://luv.asn.au/overheads/lex_yacc/yacc.html#empty_rule */
    ;

parameter_list:
    variable_list
    | /* empty */
    ;

declaration_list:
    declaration
    | declaration_list declaration
    ;

function:
    FUNC identifier '(' parameter_list ')' statement
    ;

statement:
    assignment_statement
    | return_statement
    | if_statement
    | print_statement
    | while_statement
    | null_statement
    | block
    ;

block:
    OPENBLOCK declaration_list statement_list CLOSEBLOCK
    | OPENBLOCK statement_list CLOSEBLOCK
    ;

assignment_statement:
    identifier ASSIGN expr
    ;

return_statement:
    RETURN expr
    ;

print_statement:
    PRINT print_list
    ;

null_statement:
    CONTINUE
    ;

if_statement:
    IF relation THEN statement
    | IF relation THEN statement ELSE statement
    ;

while_statement:
    WHILE relation DO statement
    ;

relation:
    expr '=' expr
    | expr '<' expr
    | expr '>' expr
    ;

expr:
    expr '+' expr
    | expr '-' expr
    | expr '|' expr
    | expr '^' expr
    | expr '&' expr
    | expr ">>" expr
    | expr "<<" expr
    | expr '*' expr
    | expr '/' expr
    | '-' expr
    | " ˜ " expr
    | '(' expr ')'
    | number 
    | identifier 
    | identifier '(' argument_list ')'
    ;

declaration:
    VAR variable_list
    ;

print_item:
    expr
    | string
    ;

identifier:
    IDENTIFIER
    ;

number:
    NUMBER
    ;

string:
    STRING
    ;
%%

int
yyerror ( const char *error )
{
    fprintf ( stderr, "%s on line %d\n", error, yylineno );
    exit ( EXIT_FAILURE );
}
