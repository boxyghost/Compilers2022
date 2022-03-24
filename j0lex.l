/* -*-bison-*- */
/* Simple wc implementation in Flex */
%option noyywrap
%option noinput
%option nounput
%{
      #include <stdlib.h>
      #include <ctype.h>
      #include <stdio.h>
      #include "j0gram.tab.h"
      #include "tree.h"
			int rows = 1, words = 0, chars = 0;



%}

%%
"//"[^\n]*   {}
"#"[^\n]*    {}
";"          {return alctoken(';');}
"\{"         {return alctoken('{');}
"\}"         {return alctoken('}');}
"\("         {return alctoken('(');}
"\)"         {return alctoken(')');}
"\""         {return alctoken(1);}
"\'"         {return alctoken(1);}
"\/\*"       {return alctoken(1);}
[\t ] {}
"boolean"    {return alctoken(BOOL);} /* Allowed reserved j0 words */
"break"      {return alctoken(BREAK);}
"case"       {return alctoken(CASE);}
"char"       {return alctoken(CHAR);}
"class"      {return alctoken(CLASS);}
"continue"   {return alctoken(CONTINUE);}
"default"    {return alctoken(DEFAULT);}
"double"     {return alctoken(DOUBLE);}
"else"       {return alctoken(ELSE);}
"float"      {return alctoken(DOUBLE);}
"for"        {return alctoken(FOR);}
"if"         {return alctoken(IF);}
"instanceof" {return alctoken(INSTANCEOF);}
"int"        {return alctoken(INT);}
"long"       {return alctoken(LONG);}
"new"        {return alctoken(NEW);}
"public"     {return alctoken(PUBLIC);}
"return"     {return alctoken(RETURN);}
"static"     {return alctoken(STATIC);}
"switch"     {return alctoken(SWITCH);}
"void"       {return alctoken(VOID);}
"while"      {return alctoken(WHILE);}
"null"       {return alctoken(NULLVAL);}
"abstract"     {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);} /* Disallowed reserved Java words (Not in j0) */
"assert"       {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"byte"         {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"catch"        {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"const"        {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"do"           {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"enum"         {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"exports"      {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"extends"      {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"final"        {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"finally"      {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"goto"         {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"implements"   {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"import"       {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"interface"    {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"module"       {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"native"       {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"package"      {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"protected"    {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"requires"     {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"short"        {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"strictfp"     {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"super"        {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"synchronized" {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"this"         {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"throw"        {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"throws"       {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"transient"    {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"try"          {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"var"          {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"volatile"     {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"private"      {printf("Word compatable with java not compatible with j0: %s Please do not use this word.", yytext); return alctoken(1);}
"="          {return alctoken('=');}
"+="         {return alctoken(ADDADD);}
"-="         {return alctoken(SUBSUB);}
"*="         {return alctoken(MULMUL);}
"/="         {return alctoken(DIVDIV);}
"%="         {return alctoken(MODMOD);}
"+"          {return alctoken('+');}
"-"          {return alctoken('-');} /* Duplicate of - below, that should be fine, just make sure to rememeber that it is overloaded... */
"*"          {return alctoken('*');}
"/"          {return alctoken('/');}
"%"          {return alctoken('%');}
"++"         {return alctoken(INCREMENT);}
"--"         {return alctoken(DECREMENT);}
"\=\="       {return alctoken(EQUALEQUAL);}
"!="         {return alctoken(NOTEQUAL);}
">"          {return alctoken('>');}
"<"          {return alctoken('<');}
">="         {return alctoken(GREATEREQUAL);}
"<="         {return alctoken(LESSEQUAL);}
"&&"         {return alctoken(ANDAND);}
"||"         {return alctoken(OROR);}
"!"          {return alctoken('!');}
"\[\]"         {return alctoken(OPENCLOSE);}
"\["         {return alctoken('[');}
"\]"         {return alctoken(']');}
"."          {return alctoken('.');}
":"             {return alctoken(':');}
","             {return alctoken(',');}
"("([A-Za-z])([A-Za-z0-9_-])*")"                {return alctoken(CAST);}
(([1-9][0-9]*)|"0")"l"?                       {return alctoken(LINT);} /* int */
(([0-9]*"."[0-9]+)|([0-9]+"."[0-9]*))"l"?       {return alctoken(LDOUBLE);} /* double */
"0"("x"|"X")[a-fA-F0-9]+                        {return alctoken(HEX);} /*hexadecimal rep*/
"0"([0-7]+)                                     {return alctoken(OCT);} /*octal rep*/
"\'"(.)"\'"|"\'"(\\.)"\'"                       {return alctoken(LCHAR);} /* char */
"\""(.)*"\""                                    {return alctoken(LSTRING);} /* String */
"/*"([^*]|"*"+[^/*])*"*"+"/"                    {int countlines();countlines();/*todo do we need to do this twice?*/}
\n		                                        {rows++;}
[A-Za-z][A-Za-z0-9]*	                        {return alctoken(IDENTIFIER);}
<<EOF>>                                         {return -1;}
[0-9]+("e"|"E")[0-9]+                           {return alctoken(LDOUBLE);}
[0-9]+"e"                               {return alctoken(1);}
.                                       {return alctoken(1);}
%%
