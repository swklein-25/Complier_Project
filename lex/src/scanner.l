%{
#include <stdint.h>

#define LIST                concatenateString(yytext)
#define TOKEN(t)            { LIST; if (opt_tok) printf("<%s>\n", #t); }
#define TOKEN_CHAR(t)       { LIST; if (opt_tok) printf("<%c>\n", (t)); }
#define TOKEN_STRING(t, s)  { LIST; if (opt_tok) printf("<%s: %s>\n", #t, (s)); }
#define TOKEN1(t)			{ LIST; if (opt_tok) printf("<%s>\n", t);}
#define MAX_LINE_LENG       512

uint32_t line_num = 1;
static char buffer[MAX_LINE_LENG];

static uint32_t opt_src = 1;
static uint32_t opt_tok = 1;
static char *buffer_ptr = buffer;
static char string_literal[MAX_LINE_LENG];

static void concatenateString(const char *yytext_ptr);

%}


%x CCOMMENT

%%
	/*Delimiter*/
"(" 	 	{ TOKEN_CHAR('('); }
":" 		{ TOKEN_CHAR(':'); }
";"  		{ TOKEN_CHAR(';'); }
")"  		{ TOKEN_CHAR('('); }
"["  		{ TOKEN_CHAR('['); }
"]"  		{ TOKEN_CHAR(']'); }
","  		{ TOKEN_CHAR(','); }
	/*Operation*/
"+"  		{ TOKEN_CHAR('+');}
"-"  		{ TOKEN_CHAR('-');}
"*"  		{ TOKEN_CHAR('*');}
"/"	  	{ TOKEN_CHAR('/');}
"mod"           { TOKEN(mod);}
":=" 		{ TOKEN(:=);}
"<"		{ TOKEN_CHAR('<');}
">"		{ TOKEN_CHAR('>');}
"<="		{ TOKEN(<=);}
"<>"		{ TOKEN(<>);}
">="		{ TOKEN(>=);}
"=" 		{ TOKEN_CHAR('=');}
"and"		{ TOKEN(and);}
"or"		{ TOKEN(or);}
"not"  		{ TOKEN(not);}
	/*Reserved word*/
"var"           { TOKEN(KWvar);}
"def" 		{ TOKEN(KWdef);}
"array"		{ TOKEN(KWarray);}
"of"		{ TOKEN(KWof);}
"boolean"	{ TOKEN(KWboolean);}
"integer"	{ TOKEN(KWinteger);}
"real"		{ TOKEN(KWreal);}
"string" 	{ TOKEN(KWstring);}
"true"		{ TOKEN(KWtrue);}
"false"  	{ TOKEN(KWfalse);}
"while"		{ TOKEN(KWwhile);}
"do"		{ TOKEN(KWdo);}
"if"		{ TOKEN(KWif);}
"then"		{ TOKEN(KWthen);}
"else"		{ TOKEN(KWelse);}
"for"		{ TOKEN(KWfor);}
"to" 		{ TOKEN(KWto);}
"begin"		{ TOKEN(KWbegin);}
"end"   	{ TOKEN(KWend);}
"print"		{ TOKEN(KWprint);}
"read"		{ TOKEN(KWread);}
"return" 	{ TOKEN(KWreturn);}
	/*Whitespace*/
[\r\t\v\f]+     {LIST;}
[ ]+	        {LIST;}
	/*identifier*/
([A-Za-z][A-Za-z0-9]*)    {TOKEN_STRING(id,yytext);}
	/*Integer(Decimal/Octal)*/
[0]+(0|1|2|3|4|5|6|7)+    {TOKEN_STRING(Octal,yytext);}
[0-9]+			  {TOKEN_STRING(Decimal,yytext);}
	/*Floating-point*/
[0-9]+(".")(0|[1-9]+)     {TOKEN_STRING(Float,yytext);}
	/*Scientific notation*/
[1-9]+|([1-9]+(".")(0|[1-9]+))("E")("+"|"-")?[0-9]+ 	{TOKEN_STRING(SciNotation,yytext);}
	/*Stirng*/
\"([^"\n]|(\"\"))*\" 	            {
	char *yyt_ptr = yytext + 1;  // +1 for skipping the first double quote "
	char *str_ptr = string_literal;
	while (*yyt_ptr) {
		if (*yyt_ptr == '"') {
            	// Handle the situation of two double quotes "" in string literal
           	if (*(yyt_ptr + 1) == '"') {
               		*str_ptr = *yyt_ptr;
                	++str_ptr;
               		yyt_ptr += 2; // move to the next character of ""
            	}else {
               		++yyt_ptr;
            	}
        	}else {  // normal character
           		*str_ptr = *yyt_ptr;
            		++str_ptr;
            		++yyt_ptr;
       		}
    	}
   	 *str_ptr = '\0';
	TOKEN_STRING(string,yytext);}
	
	/*Comment*/
(\/\/[^\t\v\f\r\n]+)			{LIST;}
\/\*[.]+[\n]+"*""/"			{LIST;}
	
	/* C Style Comment */
"/*"           { LIST; BEGIN(CCOMMENT); }
<CCOMMENT>"*/" { LIST; BEGIN(INITIAL); }
<CCOMMENT>.    { LIST; }

	/*Pseudocomment*/
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
	/*Newline*/
<INITIAL,CCOMMENT>\n {
    if (opt_src) {
        printf("%d: %s\n", line_num, buffer);
    }
    ++line_num;
    buffer[0] = '\0';
    buffer_ptr = buffer;
}

    /* Catch the character which is not accepted by rules above */
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

int main(int argc, const char **argv) {
    if (argc != 2) {
        fprintf(stderr, "Usage: ./scanner [filename]\n");
        exit(-1);
    }

    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        fprintf(stderr, "Open file error\n");
        exit(-1);
    }

    yylex();

    return 0;
}
