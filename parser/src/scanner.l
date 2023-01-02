%{
#include <stdint.h>

#include "parser.h"

#define LIST                concatenateString(yytext)
#define TOKEN(t)            { LIST; if (opt_tok) printf("<%s>", #t); }
#define TOKEN_CHAR(t)       { LIST; if (opt_tok) printf("<%c>", (t)); }
#define TOKEN_STRING(t, s)  { LIST; if (opt_tok) printf("<%s: %s>\n", #t, (s)); }
#define TOKEN_STRING1(s)  	{ LIST; if (opt_tok) printf("%s",(s)); }
#define MAX_LINE_LENG       512

uint32_t line_num = 1;
char buffer[MAX_LINE_LENG];

static uint32_t opt_src = 1;
static uint32_t opt_tok = 1;
static char string_literal[MAX_LINE_LENG];
static char *buffer_ptr = buffer;

static void concatenateString(const char *yytext_ptr);

%}

integer 0|[1-9][0-9]*
float {integer}\.(0|[0-9]*[1-9])

    /* exclusive start condition */
%x CCOMMENT

%%
    /* Delimiter */
"," { TOKEN_CHAR(',');return ','; }
";" { TOKEN_CHAR(';');return ';'; }
":" { TOKEN_CHAR(':');return ':'; }
"(" { TOKEN_CHAR('(');return '('; }
")" { TOKEN_CHAR(')');return ')'; }
"[" { TOKEN_CHAR('[');return '['; }
"]" { TOKEN_CHAR(']');return ']'; }

    /* Operator */
"+"   { TOKEN_CHAR('+');return '+'; }
"-"   { TOKEN_CHAR('-');return '-'; }
"*"   { TOKEN_CHAR('*');return '*'; }
"/"   { TOKEN_CHAR('/');return '/'; }
"mod" { TOKEN(mod);return MOD; }
":="  { TOKEN(:=);return ASSIGN;  }
"<"   { TOKEN_CHAR('<');return '<'; }
"<="  { TOKEN(<=);return LESSTHANANDEQUAL; }
"<>"  { TOKEN(<>);return NOTGREATERANDLESS; }
">="  { TOKEN(>=);return GREATERTHANANDEQUAL; }
">"   { TOKEN_CHAR('>');return '>'; }
"="   { TOKEN_CHAR('=');return '='; }
"and" { TOKEN(and);return AND; }
"or"  { TOKEN(or);return OR; }
"not" { TOKEN(not);return NOT; }

    /* Reserved Word */
"var"     { TOKEN(var);return VAR; }
"array"   { TOKEN(array);return ARRAY; }
"of"      { TOKEN(of);return OF; }
"boolean" { TOKEN(boolean);return BOOL; }
"integer" { TOKEN(integer);return INTEGER; }
"real"    { TOKEN(real);return REAL; }
"string"  { TOKEN(string);return STRING; }

"true"    { TOKEN(true);return TRUE; }
"false"   { TOKEN(false);return FALSE; }

"def"     { TOKEN(def);return DEF; }
"return"  { TOKEN(return);return RETURN; }

"begin"   { TOKEN(begin);return Begin; }
"end"     { TOKEN(end);return END; }

"while"   { TOKEN(while);return WHILE; }
"do"      { TOKEN(do);return DO; }

"if"      { TOKEN(if);return IF; }
"then"    { TOKEN(then);return THEN; }
"else"    { TOKEN(else);return ELSE; }

"for"     { TOKEN(for);return FOR; }
"to"      { TOKEN(to);return TO; }

"print"   { TOKEN(print);return PRINT; }
"read"    { TOKEN(read);return READ; }

    /* Identifier */
[a-zA-Z][a-zA-Z0-9]* { TOKEN_STRING1(yytext);return ID; }

    /* Integer (decimal/octal) */
{integer} { TOKEN_STRING1(yytext);return Decimal; }
0[0-7]+   { TOKEN_STRING1(yytext);return Octal; }

    /* Floating-Point */
{float} { TOKEN_STRING1(yytext);return Float; }

    /* Scientific Notation [Ee][+-]?[0-9]+ */
({integer}|{float})[Ee][+-]?({integer}) { TOKEN_STRING1(yytext);return SciNotation; }

    /* String */
\"([^"\n]|\"\")*\" {
    char *yyt_ptr = yytext + 1;  // +1 for skipping the first double quote "
    char *str_ptr = string_literal;

    while (*yyt_ptr) {
        if (*yyt_ptr == '"') {
            // Handle the situation of two double quotes "" in string literal
            if (*(yyt_ptr + 1) == '"') {
                *str_ptr = *yyt_ptr;
                ++str_ptr;
                yyt_ptr += 2; // move to the next character of ""
            } else {
                ++yyt_ptr;
            }
        } else {  // normal character
            *str_ptr = *yyt_ptr;
            ++str_ptr;
            ++yyt_ptr;
        }
    }
    *str_ptr = '\0';
	TOKEN_STRING1(yytext);
    return STRINGLITERAL;
}

    /* Whitespace */
[ \t]+ { LIST; }

    /* Pseudocomment */
"//&"[ST][+-].* {
    LIST;
    char option = yytext[3];
    switch (option) {
    case 'S':
        opt_src = (yytext[4] == '+') ? 1 : 0;
        break;
    case 'T':
        opt_tok = (yytext[4] == '+') ? 1 : 0;
        break;
    }
}

    /* C++ Style Comment */
"//".* { LIST; }

    /* C Style Comment */
"/*"           { LIST; BEGIN(CCOMMENT); }
<CCOMMENT>"*/" { LIST; BEGIN(INITIAL); }
<CCOMMENT>.    { LIST; }

    /* Newline */
<INITIAL,CCOMMENT>\n {
    if (opt_src) {
        printf("%d: %s\n", line_num, buffer);
    }
    ++line_num;
    buffer[0] = '\0';
    buffer_ptr = buffer;
}

    /* Catch the character which is not accepted by all rules above */
. {
    printf("Error at line %d: bad character \"%s\"\n", line_num, yytext);
    exit(-1);
}

%%

static void concatenateString(const char *yytext_ptr) {
    while (*yytext_ptr) {
        *buffer_ptr = *yytext_ptr;
        ++buffer_ptr;
        ++yytext_ptr;
    }
    *buffer_ptr = '\0';
}
