//#include "tree.h"
#include "j0gram.tab.h"
#include "symtabentry.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

FILE *yyin;
int yyparse();
char file_name_in[128];

int symtab = 0; // Commandline option to print human readable symbol table

extern struct tree * top;
extern char * yytext;
extern YYSTYPE yylval;

extern int rows;
extern int words;
extern int chars;

void yyerror(char *s) {
  tree_print(yylval.treeptr, 0);
  //tree_print(top, 0);
  fprintf(stderr, "Error in %s: %s\nSymbol: \"%s\" provided a syntax error on line %d \n", file_name_in, s, yytext, rows); exit(2);
}

int main(int argc, char const *argv[]) {
    for (int i = 1; i < argc; i++) {
        // Check for commandline arguments (This should be changed if scale increases -B)
        if (strncmp(argv[i], "-symtab", 7*sizeof(char)) == 0) symtab = 1;
    }

    for (size_t file_count = 1; file_count < argc; file_count++) {
          int inlen = strlen(argv[file_count]);

          strncpy(file_name_in, argv[file_count], 128);
          if (inlen < 6 || argv[file_count][inlen - 5] != '.' || argv[file_count][inlen - 4] != 'j' || argv[file_count][inlen - 3] != 'a' || argv[file_count][inlen - 2] != 'v' || argv[file_count][inlen - 1] != 'a') {
            //printf("You didn't add .java to the end but we will try anyways...\n");
            char j[] = ".java";
            strncat(file_name_in, j, 5);
          }
          yyin = fopen(file_name_in, "r");
          if (yyin == NULL) {
            printf("Error: Please supply file name as command line argument, ending in \".java\".\n");
            return -1;
          }

          yyparse();//printf("yyparse returns %d.\n\n\n", yyparse());
           // tree_print(top, 0);
            // print_graph(top, "dot.dot");
          //printsyms(top);
          cleanup_tree(top);
          struct sym_table * table = mksymtab(NULL);
          if (add_sym_entry(top, table) != 0) {
            printf("Failed to compile due to symbolic error.\n");
            return 3; // error!
          }

            printf("--- symbol table for: Global\n");
          printtable(table, 0);

          if (check_all_unchecked(table) != 0) {
            printf("Failed to compile due to symbolic error.\n");
            return 3;
          }
    }

    return 0;
}

int countlines(){
  for (int i = 0; i < strlen(yytext); i++){
    if (yytext[i] == '\n'){
      rows++;
    }
  }
  return 1;
}
