#include "tree.h"
#include "j0gram.tab.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <errno.h>

extern YYSTYPE yylval;
extern char * yytext;
extern int rows;
extern int words;
extern int chars;
struct tree *top;
extern char file_name_in[128];

int serial = 0;

//todo the create destroy and traverse tree

void printsymbol(char *s)
{
   printf("%s\n", s); fflush(stdout);
}

void printsyms(struct tree * t) {
    if (t == NULL) {
      return;
    }

    if (t->leaf != NULL && t->leaf->category == IDENTIFIER) {
      printsymbol(t->symbolname);
    }

    for (int i = 0; i < t->nkids; i++) {
        printsyms(t->kids[i]);
    }
  }

void printnode(struct tree *t) {
  if (t->symbolname != NULL) {
    printf("Symbol Name: %s, ", t->symbolname);
  } else {
    // printf("Symbol Name NULL, ");
  }
  printf("production rule: %i, number of kids: %i\n", t->prodrule, /*t->fname,*/ t->nkids);
}

int alctoken(int i) {

  if (i == 1) {
    fprintf(stderr, "Error in %s:\nSymbol: \"%s\" provided a lexical error on line %d \n", file_name_in, yytext, rows); exit(2);
    exit(1);
  }
  // printf("%d\n", i);
  yylval.treeptr = calloc(1, sizeof(struct tree));
  yylval.treeptr->prodrule = i;
  yylval.treeptr->id = serial++;
  // yylval.treeptr->fname = fname;

  yylval.treeptr->symbolname = calloc(sizeof(char), 128);
  //printf("%s\n", yytext);
  strncpy(yylval.treeptr->symbolname, yytext, 128);

  yylval.treeptr->nkids = 0; // handle this. maybe number of kids?
  yylval.treeptr->leaf = calloc(1, sizeof(struct token));

  yylval.treeptr->leaf->category = i;
  yylval.treeptr->leaf->text = (char *)calloc(1, strlen(yytext)+1);//todo figure out how to do this lol
  strncpy(yylval.treeptr->leaf->text, yytext, strlen(yytext));
  yylval.treeptr->leaf->lineno = rows;
  yylval.treeptr->leaf->filename = (char *)calloc(1, strlen(file_name_in)+1);
  strncpy(yylval.treeptr->leaf->filename, file_name_in, strlen(file_name_in));

  if(i == LINT){ //Integers
      yylval.treeptr->leaf->ival = atoi(yytext);
  } else if(i == LDOUBLE){ //Doubles(floats)
      yylval.treeptr->leaf->dval = atof(yytext);
  } else if(i == LSTRING){ // Strings
      char *temp_str = delimiters();
      int esc_counter = 0;
      //casting to a new str to find escapes characters
      char *new_str = (char *)malloc(sizeof(char)*((strlen(temp_str)-esc_counter)+1));
      str_deescape(temp_str, new_str);
      yylval.treeptr->leaf->sval = new_str;
  } else if (i == LCHAR){
        char * temp_char = delimiters();
        int esc_counter = 0;
        char *new_str = (char *)malloc(sizeof(char)*((strlen(temp_char)-esc_counter)+1));
        str_deescape(temp_char, new_str);
        yylval.treeptr->leaf->text = new_str;
    }

  // printnode(yylval.treeptr);

  return i;
}


struct tree * kido(int i){
  struct tree * r = calloc(1, sizeof(struct tree));
  r->id = serial++;
  r->prodrule = i;

  r->symbolname = calloc(sizeof(char), 128);
  strncpy(r->symbolname, yytext, 128);

  //printf("%s\n", yytext);

  r->nkids = 0; // handle this. maybe number of kids?
  r->leaf = calloc(1, sizeof(struct token));
  r->leaf->category = i;

  // printnode(yylval.treeptr);

  return r;
}

// Replacement tree generation function
// Allows for tree creation for any number of children
struct tree *make_tree(int pr, char *symb, int nkids, ...){
    struct tree *t = NULL;
    t = malloc(sizeof(struct tree));
    if (!t) exit(ENOMEM);

    t->prodrule = pr;
    t->symbolname = strdup(symb); // Need to handle memory better here?
    t->nkids = nkids;
    t->id = serial++;

    va_list valist;
    va_start(valist, nkids); // Get all arguments after nkids
    
    int i;
    for (i = 0; i < nkids; i++) {
        t->kids[i] = va_arg(valist, struct tree*);
    }

    va_end(valist);
    yylval.treeptr = t;
    return t;
    
}


struct tree * alcTreeOneKids(struct tree * kid, int prule) {
  yylval.treeptr = calloc(1, sizeof(struct tree));
  yylval.treeptr->id = serial++;
  yylval.treeptr->prodrule = prule;

  yylval.treeptr->symbolname = NULL;
  // strncpy(yylval.treeptr->symbolname, yytext, 128);

  yylval.treeptr->nkids = 1; // handle this. maybe number of kids?
  yylval.treeptr->leaf = NULL;//calloc(1, sizeof(struct token));
  // yylval.treeptr->leaf->catagory = i;
  yylval.treeptr->kids[0] = kid;

  // printnode(yylval.treeptr);

  return yylval.treeptr;
}
struct tree * alcTreeTwoKids(struct tree * kid1, struct tree * kid2, int prule) {
  yylval.treeptr = calloc(1, sizeof(struct tree));

  yylval.treeptr->id = serial++;
  yylval.treeptr->prodrule = prule;

  yylval.treeptr->symbolname = NULL;
  // strncpy(yylval.treeptr->symbolname, yytext, 128);

  yylval.treeptr->nkids = 2; // handle this. maybe number of kids?
  yylval.treeptr->leaf = NULL;//calloc(1, sizeof(struct token));
  // yylval.treeptr->leaf->catagory = i;
  yylval.treeptr->kids[0] = kid1;
  yylval.treeptr->kids[1] = kid2;

  // printnode(yylval.treeptr);

  return yylval.treeptr;
}
struct tree * alcTreeThreeKids(struct tree * kid1, struct tree * kid2, struct tree * kid3, int prule) {
  yylval.treeptr = calloc(1, sizeof(struct tree));

  yylval.treeptr->id = serial++;
  yylval.treeptr->prodrule = prule;

  yylval.treeptr->symbolname = NULL;
  // strncpy(yylval.treeptr->symbolname, yytext, 128);

  yylval.treeptr->nkids = 3; // handle this. maybe number of kids?
  yylval.treeptr->leaf = NULL;//calloc(1, sizeof(struct token));
  // yylval.treeptr->leaf->catagory = i;
  yylval.treeptr->kids[0] = kid1;
  yylval.treeptr->kids[1] = kid2;
  yylval.treeptr->kids[2] = kid3;

  // printnode(yylval.treeptr);

  return yylval.treeptr;
}
struct tree * alcTreeFourKids(struct tree * kid1, struct tree * kid2, struct tree * kid3, struct tree * kid4, int prule) {
  yylval.treeptr = calloc(1, sizeof(struct tree));

  yylval.treeptr->id = serial++;
  yylval.treeptr->prodrule = prule;

  yylval.treeptr->symbolname = NULL;
  // strncpy(yylval.treeptr->symbolname, yytext, 128);

  yylval.treeptr->nkids = 4; // handle this. maybe number of kids?
  yylval.treeptr->leaf = NULL;//calloc(1, sizeof(struct token));
  // yylval.treeptr->leaf->catagory = i;
  yylval.treeptr->kids[0] = kid1;
  yylval.treeptr->kids[1] = kid2;
  yylval.treeptr->kids[2] = kid3;
  yylval.treeptr->kids[3] = kid4;

    // tree_print(yylval.treeptr, 4);

  // printnode(yylval.treeptr);

  return yylval.treeptr;
}
struct tree * alcTreeFiveKids(struct tree * kid1, struct tree * kid2, struct tree * kid3, struct tree * kid4, struct tree * kid5, int prule) {
  yylval.treeptr = calloc(1, sizeof(struct tree));

  yylval.treeptr->id = serial++;
  yylval.treeptr->prodrule = prule;

  yylval.treeptr->symbolname = NULL;
  // strncpy(yylval.treeptr->symbolname, yytext, 128);

  yylval.treeptr->nkids = 5; // handle this. maybe number of kids?
  yylval.treeptr->leaf = NULL;//calloc(1, sizeof(struct token));
  // yylval.treeptr->leaf->catagory = i;
  yylval.treeptr->kids[0] = kid1;
  yylval.treeptr->kids[1] = kid2;
  yylval.treeptr->kids[2] = kid3;
  yylval.treeptr->kids[3] = kid4;
  yylval.treeptr->kids[4] = kid5;

  // printnode(yylval.treeptr);

  return yylval.treeptr;
}
struct tree * alcTreeSixKids(struct tree * kid1, struct tree * kid2, struct tree * kid3, struct tree * kid4, struct tree * kid5, struct tree * kid6, int prule) {
  yylval.treeptr = calloc(1, sizeof(struct tree));

  yylval.treeptr->id = serial++;
  yylval.treeptr->prodrule = prule;

  yylval.treeptr->symbolname = NULL;
  // strncpy(yylval.treeptr->symbolname, yytext, 128);

  yylval.treeptr->nkids = 6; // handle this. maybe number of kids?
  yylval.treeptr->leaf = NULL;//calloc(1, sizeof(struct token));
  // yylval.treeptr->leaf->catagory = i;
  yylval.treeptr->kids[0] = kid1;
  yylval.treeptr->kids[1] = kid2;
  yylval.treeptr->kids[2] = kid3;
  yylval.treeptr->kids[3] = kid4;
  yylval.treeptr->kids[4] = kid5;
  yylval.treeptr->kids[5] = kid6;

  // printnode(yylval.treeptr);

  return yylval.treeptr;
}

void tree_print(struct tree * t, int level) {
  if (t == NULL) {
    for (int i = 0; i <= level; i++) {
      printf(" ");
    }
    printf("Empty Node\n");
    return;
  }
  // if (t->nkids == 1 && t->prodrule > 999) {
  //   tree_print(t->kids[1], level);
  //   return;
  // }
  for (int i = 0; i <= level; i++) {
    printf("  ");
  }

  printnode(t);
  for (int i = 0; i < t->nkids; i++) {
    //if (t->kids[i] != NULL) {
      tree_print(t->kids[i], level + 1);
    // } else {
    //   for (int i = 0; i <= level + 1; i++) {
    //     printf("\t");
    //   }
    //   printf("This seems to be empty...\n");
    // }
  }
}

char *yyname(int sym);

char *escape(char *s) {
  if (s == NULL) {
    return "NULL";
  }
   char *s2 = malloc(strlen(s)+16);
   if (s[0] == '\"') {
      if (s[strlen(s)-1] != '\"') {
  	     fprintf(stderr, "What is it?!\n");
  	  }
      char * dest = malloc(strlen(s)+16);;
      strcpy(dest, "\\");
      strcat(s2, dest);
      strcat(s2, s);
      //strcpy(dest, "\\\"");
      //strcat(s2 - 1, dest);
      s2[strlen(s)] = '\\';
      s2[strlen(s) + 1] = '\"';
      // sprintf(s2, "\\%s", s);
      // strcat(s2+strlen(s2)-1, "\\\"");
      // return s2;
      return s2;
     }
   else return s;
}

char *pretty_print_name(struct tree *t) {
   char *s2 = malloc(40);
   if (t->leaf == NULL) {
      sprintf(s2, "%s#%d", t->symbolname, t->prodrule%10);
      return s2;
      }
   else {
      sprintf(s2,"%s:%d", escape(t->leaf->text), t->leaf->category);
      return s2;
      }
}

void print_leaf(struct tree *t, FILE *f) {
  char * s = yyname(t->leaf->category);
   // print_branch(t, f);
   fprintf(f, "N%d [shape=box style=dotted label=\" %s \\n ", t->id, s);
   fprintf(f, "text = %s \\l lineno = %d \\l\"];\n", escape(t->leaf->text), t->leaf->lineno);
}
void print_branch(struct tree *t, FILE *f) {
  fprintf(f, "N%d [shape=box label=\"%s\"];\n", t->id, pretty_print_name(t));
}
void print_graph(struct tree *t, char * filename) {
  FILE *f = fopen(filename, "w");
  if (f == NULL) {
    printf("Couldn't open file\"%s\".\n", filename);
    exit(0);
  }
  fprintf(f, "digraph {\n");
  print_subgraph(t, f);
  fprintf(f, "}\n");
  fclose(f);
}
void print_subgraph(struct tree *t, FILE *f) {
  if (t->leaf != NULL) {
    print_leaf(t, f);
    return;
  }
  print_branch(t, f); // redo This
  for (int i = 0; i < t->nkids; i++) {
    if (t->kids[i] != NULL) {
      fprintf(f, "N%d -> N%d;\n", t->id, t->kids[i]->id);
	    print_subgraph(t->kids[i], f);
	  } else {
      fprintf(f, "N%d -> N%d%d;\n", t->id, t->id, serial);
      fprintf(f, "N%d%d [label=\"%s\"];\n", t->id, serial, "Empty rule");
      serial++;
    }
  }
}
// int alcTreeTwoKids() {
//
// }
// int alcTreeThreeKids() {
//
// }
struct tree * bingo(struct tree * kid1, struct tree * kid2, struct tree * kid3, struct tree * kid4) {
  top = alcTreeFourKids(kid1, kid2, kid3, kid4, 1000);
  return top;
}
char *delimiters(){
    char *str_lim = (char *)calloc(1, strlen(yytext)-1);
    //printf("yytext: %s legnth: %ld\n", yytext, strlen(yytext));
    strncpy(str_lim, yytext+1, strlen(yytext)-2);
    //printf("yytext: %s legnth: %ld\n", str_lim, strlen(str_lim));
    return str_lim;
}

void str_deescape(char *str, char *new_str){

    int i = 0;
    int offset = 0;

    while (i < strlen(str)){ // while loop for looping through each string
        if (str[i] == '\\'){ // looking for backlash
            switch (str[i + 1]){
                case 'a':
                    new_str[i - offset] = '\a'; break;

                case 'b':
                    new_str[i - offset] = '\b'; break;

                case 'f':
                    new_str[i - offset] = '\f'; break;

                case 'n':
                    new_str[i - offset] = '\n'; break;

                case 'r':
                    new_str[i - offset] = '\r'; break;

                case 't':
                    new_str[i - offset] = '\t'; break;

                case 'v':
                    new_str[i - offset] = '\v'; break;

    	       // case 'x': Not actually a part of Java
                    //new_str[i - offset] = '\x'; break;

                case '\\':
                    new_str[i - offset] = '\\'; break;

                case '\'':
                    new_str[i - offset] = '\''; break;

                case '"':
                    new_str[i - offset] = '\"'; break;

                case '0':
                    new_str[i - offset] = '\0'; break;

                case '?':
                    new_str[i - offset] = '\?'; break;

                }
                i++;
                offset++;
            }
            else
                new_str[i - offset] = str[i];
            i++;
        }
        new_str[i - offset] = '\0';
}
