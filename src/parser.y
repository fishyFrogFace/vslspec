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
        $$ = node_init ( root, PROGRAM, NULL, 0 );
    }
    ;

global_list:
    global {
        $$ = make_node(GLOBAL_LIST, NULL, 1, $1);
    }
    | global_list global {
        $$ = make_node(GLOBAL_LIST, NULL, 2, $1, $2);
    }
    ;

global:
    function {
        $$ = make_node(GLOBAL, NULL, 1, $1);
    }
    | declaration {
        $$ = make_node(GLOBAL, NULL, 1, $1);
    }
    ;

statement_list:
    statement {
        $$ = make_node(STATEMENT_LIST, NULL, 1, $1);
    }
    | statement_list statement {
        $$ = make_node(STATEMENT_LIST, NULL, 1, $1);
    }
    ;

print_list:
    print_item {
        $$ = make_node(PRINT_LIST, NULL, 1, $1);
    }
    | print_list ',' print_item {
        $$ = make_node(PRINT_LIST, NULL, 2, $1, $3);
    }
    ;

expr_list:
    expr {
        $$ = make_node(EXPRESSION_LIST, NULL, 1, $1);
    }
    | expr_list ',' expr {
        $$ = make_node(EXPRESSION_LIST, NULL, 2, $1, $3);
    }
    ;

variable_list:
    identifier {
        $$ = make_node(VARIABLE_LIST, NULL, 1, $1);
    }
    | variable_list ',' identifier {
        $$ = make_node(VARIABLE_LIST, NULL, 2, $1, $3);
    }
    ;

argument_list:
    expr_list {
        $$ = make_node(ARGUMENT_LIST, NULL, 1, $1);
    }
    | /* empty */ /* implicit empty rule = sadness, https://luv.asn.au/overheads/lex_yacc/yacc.html#empty_rule */ {
        $$ = make_node(ARGUMENT_LIST, NULL, 0);
    }
    ;

parameter_list:
    variable_list {
        $$ = make_node(PARAMETER_LIST, NULL, 1, $1);
    }
    | /* empty */ {
        $$ = make_node(PARAMETER_LIST, NULL, 0);
    }
    ;

declaration_list:
    declaration {
        $$ = make_node(DECLARATION_LIST, NULL, 1, $1);
    }
    | declaration_list declaration {
        $$ = make_node(DECLARATION_LIST, NULL, 2, $1, $2);
    }
    ;

function:
    FUNC identifier '(' parameter_list ')' statement {
        $$ = make_node(FUNCTION, NULL, 3, $1, $4, $6);
    }
    ;

statement:
    assignment_statement {
        $$ = make_node(STATEMENT, NULL, 1, $1);
    }
    | return_statement {
        $$ = make_node(STATEMENT, NULL, 1, $1);
    }
    | if_statement {
        $$ = make_node(STATEMENT, NULL, 1, $1);
    }
    | print_statement {
        $$ = make_node(STATEMENT, NULL, 1, $1);
    }
    | while_statement {
        $$ = make_node(STATEMENT, NULL, 1, $1);
    }
    | null_statement {
        $$ = make_node(STATEMENT, NULL, 1, $1);
    }
    | block {
        $$ = make_node(STATEMENT, NULL, 1, $1);
    }
    ;

block:
    OPENBLOCK declaration_list statement_list CLOSEBLOCK {
        $$ = make_node(BLOCK, NULL, 2, $2, $3);
    }
    | OPENBLOCK statement_list CLOSEBLOCK {
        $$ = make_node(BLOCK, NULL, 1, $1);
    }
    ;

assignment_statement:
    identifier ASSIGN expr {
        $$ = make_node(ASSIGNMENT_STATEMENT, NULL, 2, $1, $3);
    }
    ;

return_statement:
    RETURN expr {
        $$ = make_node(RETURN_STATEMENT, NULL, 1, $2);
    }
    ;

print_statement:
    PRINT print_list {
        $$ = make_node(PRINT_STATEMENT, NULL, 1, $2);
    }
    ;

null_statement:
    CONTINUE {
        $$ = make_node(NULL_STATEMENT, NULL, 0);
    }
    ;

if_statement:
    IF relation THEN statement {
        $$ = make_node(IF_STATEMENT, NULL, 2, $2, $4);
    }
    | IF relation THEN statement ELSE statement {
        $$ = make_node(IF_STATEMENT, NULL, 3, $2, $4, $6);
    }
    ;

while_statement:
    WHILE relation DO statement {
        $$ = make_node(WHILE_STATEMENT, NULL, 2, $2, $4);
    }
    ;

relation:
    expr '=' expr {
        $$ = make_node(RELATION, strdup("="), 2, $1, $2);
    }
    | expr '<' expr {
        $$ = make_node(RELATION, strdup("<"), 2, $1, $2);
    }
    | expr '>' expr {
        $$ = make_node(RELATION, strdup(">"), 2, $1, $2);
    }
    ;

expr:
    expr '+' expr {
        $$ = make_node(EXPRESSION, strdup("+"), 2, $1, $2); 
    }
    | expr '-' expr {
        $$ = make_node(EXPRESSION, strdup("-"), 2, $1, $2); 
    }
    | expr '|' expr {
        $$ = make_node(EXPRESSION, strdup("|"), 2, $1, $2); 
    }
    | expr '^' expr {
        $$ = make_node(EXPRESSION, strdup("^"), 2, $1, $2); 
    }
    | expr '&' expr {
        $$ = make_node(EXPRESSION, strdup("&"), 2, $1, $2); 
    }
    | expr RSHIFT expr {
        $$ = make_node(EXPRESSION, strdup("RSHIFT"), 2, $1, $2); 
    }
    | expr LSHIFT expr {
        $$ = make_node(EXPRESSION, strdup("LSHIFT"), 2, $1, $2); 
    }
    | expr '*' expr {
        $$ = make_node(EXPRESSION, strdup("*"), 2, $1, $2); 
    }
    | expr '/' expr {
        $$ = make_node(EXPRESSION, strdup("/"), 2, $1, $2); 
    }
    | '-' expr {
        $$ = make_node(EXPRESSION, strdup("+"), 1, $2); 
    }
    | '~' expr {
        $$ = make_node(EXPRESSION, strdup("~"), 1, $2); 
    }
    | '(' expr ')' {
        $$ = make_node(EXPRESSION, strdup("()"), 1, $2); 
    }
    | number  {
        $$ = $1; 
    }
    | identifier  {
        $$ = $1; 
    }
    | identifier '(' argument_list ')' {
        $$ = make_node(EXPRESSION, strdup("idarglist"), 2, $1, $3);
    }
    ;

declaration:
    VAR variable_list {
        $$ = make_node(DECLARATION, NULL, 1, $1);
    }
    ;

print_item:
    expr {
        $$ = make_node(PRINT_ITEM, NULL, 1, $1);
    }
    | string {
        $$ = make_node(PRINT_ITEM, NULL, 1, $1);
    }
    ;

identifier:
    IDENTIFIER {
        $$ = make_node(IDENTIFIER_DATA, strdup("thedata"), 0);
    }
    ;

number:
    NUMBER {
        $$ = make_node(NUMBER_DATA, strdup("thedata"), 0);
    }
    ;

string:
    STRING {
        $$ = make_node(STRING_DATA, strdup("thedata"), 0);
    }
    ;
%%

int
yyerror ( const char *error )
{
    fprintf ( stderr, "%s on line %d\n", error, yylineno );
    exit ( EXIT_FAILURE );
}
