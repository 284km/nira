%{
#include <stdio.h>
#include <string.h>
#include <string>
#include <sstream>
#include "Nira.tab.hh"

extern "C" int yywrap();

/**
 * string buffer
 */
static std::stringstream string_buffer;

static void nira_open_string_literal() {
    string_buffer.str("");
}
static void nira_add_string_literal(char c) {
    string_buffer << c;
}
static const char *nira_close_string_literal() {
    return string_buffer.str().c_str();
}

/**
 * line number
 */
static int line_number = 0;
static void increment_line_number() {
    line_number++;
}

// yywrap?
int yywrap(void)
{
    return 1;
}

%}

%start C_COMMENT CC_COMMENT STRING_LITERAL_STATE PERL_COMMENT

%%

<INITIAL>"+"        return ADD;
<INITIAL>"-"        return SUB;
<INITIAL>"*"        return MUL;
<INITIAL>"/"        return DIV;
<INITIAL>"\n"       return CR;

<INITIAL>[1-9][0-9]* {
    int tmp;
    sscanf(yytext, "%d", &tmp);
    yylval.int_value = tmp;
    return INT_LITERAL;
}

<INITIAL>"if" return IF;
<INITIAL>"(" return L_PAREN;
<INITIAL>")" return R_PAREN;
<INITIAL>"{" return L_BRACE;
<INITIAL>"}" return R_BRACE;
<INITIAL>"true" return TRUE;
<INITIAL>"false" return FALSE;
<INITIAL>[ \t] ;
<INITIAL>[ \t\r\n] {
    increment_line_number();
    return CR;
}

<INITIAL>[A-Za-z_][A-Za-z0-9_]* {
    char *tmp = new char [strlen(yytext)+1];
    strcpy(tmp, yytext);
    // printf("GET IDENTIFIER in LEX: '%s'\n", tmp);
    yylval.str_value = tmp;
    return IDENTIFIER;
}

<INITIAL>\" {
    nira_open_string_literal();
    BEGIN STRING_LITERAL_STATE;
}

<INITIAL>"/*" {
    BEGIN C_COMMENT;
}
<INITIAL>"//" {
    BEGIN CC_COMMENT;
}
<INITIAL>"#" {
    BEGIN PERL_COMMENT;
}

<C_COMMENT>\n     increment_line_number();
<C_COMMENT>"*/"     {
    BEGIN INITIAL;
}
<C_COMMENT>.      ;
<CC_COMMENT>\n  {
    increment_line_number();
    BEGIN INITIAL;
}
<CC_COMMENT>.   ;
<PERL_COMMENT>\n  {
    increment_line_number();
    BEGIN INITIAL;
}
<PERL_COMMENT>.   ;

<STRING_LITERAL_STATE>\"        {
    yylval.str_value = strdup(nira_close_string_literal());
    BEGIN INITIAL;
    return STRING_LITERAL;
}
<STRING_LITERAL_STATE>\n        {
    nira_add_string_literal('\n');
    increment_line_number();
}
<STRING_LITERAL_STATE>\\\"      nira_add_string_literal('"');
<STRING_LITERAL_STATE>\\n       nira_add_string_literal('\n');
<STRING_LITERAL_STATE>\\t       nira_add_string_literal('\t');
<STRING_LITERAL_STATE>\\\\      nira_add_string_literal('\\');
<STRING_LITERAL_STATE>[\x81-\x9f\xe0-\xef][\x40-\x7e\x80-\xfc] {
  nira_add_string_literal(yytext[0]);
  nira_add_string_literal(yytext[1]);
}
<STRING_LITERAL_STATE>.         nira_add_string_literal(yytext[0]);

%%
