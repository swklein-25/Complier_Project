%{
#include <assert.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

extern int32_t line_num;  /* declared in scanner.l */
extern char buffer[];     /* declared in scanner.l */
extern FILE *yyin;        /* declared by lex */
extern char *yytext;      /* declared by lex */

extern int yylex(void); 
static void yyerror(const char *msg);
%}

%token ID BOOL INTEGER REAL STRING ARRAY VAR OF TRUE FALSE DEF RETURN Begin END WHILE
%token DO IF THEN ELSE FOR TO PRINT READ Decimal Octal Float SciNotation STRINGLITERAL ASSIGN 
%token NOTGREATERANDLESS MOD LESSTHANANDEQUAL GREATERTHANANDEQUAL AND OR NOT
%%

ProgramName: ID ';' declaration_list function_list compound_stat END;
declaration_list: |declarationvar|declarationconst|declaration_list declarationvar|declaration_list declarationconst;
declarationvar: VAR identifier_list ':' scalartype ';';
declarationvar: VAR identifier_list ':' arraytype  ';'; 
arraytype: arraytypepursudo scalartype;
arraytypepursudo:|arraytypepursudo ARRAY Decimal OF;
declarationconst:VAR identifier_list ':' literal_constant ';';

function_list: |founctiondecl|founctiondef|function_list founctiondecl|function_list founctiondef;
founctiondecl: ID '(' arguments ')' returntype ';'; 
founctiondef: ID '(' arguments ')' returntype  compound_stat END;
returntype:|':' scalartype;
scalartype: BOOL|INTEGER|REAL|STRING;
arguments: |arguments1;
arguments1:argument |arguments1 ';' argument;
argument: identifier_list ':' basictype;
basictype: ARRAY|BOOL|INTEGER|REAL|STRING;
identifier_list: ID identifier_list_1;
identifier_list_1:|',' ID identifier_list_1;
compound_stat: Begin declaration_list statement_list END;
statement_list:|statement_list compound_stat|statement_list simple_statement |statement_list conditional|statement_list while_statement|statement_list for_statement|statement_list return_statement|statement_list fuctioncallstatement;
simple_statement: assignment |printstatement|readstatement;
assignment:variable_reference ASSIGN expression ';';
variable_reference:ID subreference ;
subreference:|'[' Decimal ']' subreference|'[' subexpression ']' subreference;
printstatement:PRINT expression ';';
readstatement:READ variable_reference ';';
conditional:IF expression THEN compound_stat ELSE compound_stat END IF|IF expression THEN compound_stat END IF;
while_statement:WHILE expression DO compound_stat END DO;
for_statement:FOR ID ASSIGN Decimal TO Decimal DO compound_stat END DO;
return_statement:RETURN expression ';';
fuctioncallstatement:fuctioncall ';';
fuctioncall:ID '(' expression_list ')';
expression_list:|expression_list_1;
expression_list_1:expression|expression_list_1 ',' expression;
expression:subexpression|'(' expression ')';
subexpression:literal_constant|variable_reference|fuctioncall|arithmeticexp|logicalexp;
literal_constant:Decimal|Octal|Float|STRINGLITERAL|TRUE|FALSE|'-' Decimal|'-' Octal|'-' Float|'+' Decimal|'+' Octal|'+' Float|SciNotation ;
logicalexp:sublogicalexp|logicalexp AND sublogicalexp|logicalexp OR sublogicalexp|NOT sublogicalexp|NOT logicalexp;
sublogicalexp:arithmeticexp|sublogicalexp '=' arithmeticexp|sublogicalexp '>' arithmeticexp|sublogicalexp GREATERTHANANDEQUAL arithmeticexp;
sublogicalexp:sublogicalexp NOTGREATERANDLESS arithmeticexp|sublogicalexp LESSTHANANDEQUAL arithmeticexp|sublogicalexp '<' arithmeticexp;
arithmeticexp: factor|arithmeticexp '+' factor|arithmeticexp '-' factor|'(' arithmeticexp '+' factor ')'|'(' arithmeticexp '-' factor ')'|'(' arithmeticexp '*' factor ')'|'(' arithmeticexp '/' factor ')';
arithmeticexp:'(' arithmeticexp ')';
factor:subfactor|'-' subfactor|factor '*' subfactor|factor '/' subfactor|factor MOD subfactor|'(' factor ')'|'-' factor;
subfactor:term|'(' subfactor '+' term ')'|'(' subfactor '-' term ')'|'(' subfactor '*' term ')'|'(' subfactor '/' term ')'|'(' subfactor ')';
term:literal_constant|'(' literal_constant ')'|variable_reference|'(' variable_reference ')'|fuctioncall|'('fuctioncall')';
%%

void yyerror(const char *msg) {
    fprintf(stderr,
            "\n"
            "|-----------------------------------------------------------------"
            "---------\n"
            "| Error found in Line #%d: %s\n"
            "|\n"
            "| Unmatched token: %s\n"
            "|-----------------------------------------------------------------"
            "---------\n",
            line_num, buffer, yytext);
    exit(-1);
}

int main(int argc, const char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: ./parser <filename>\n");
        exit(-1);
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        perror("fopen() failed:");
    }

    yyparse();

    printf("\n"
           "|--------------------------------|\n"
           "|  There is no syntactic error!  |\n"
           "|--------------------------------|\n");
    return 0;
}
